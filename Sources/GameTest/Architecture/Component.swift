
protocol ComponentCategory: Hashable, Comparable {}

extension Never: ComponentCategory {}

protocol OpaqueComponent {
    func destroy()
}

protocol Component: OpaqueComponent {
    associatedtype InitArguments
    associatedtype Categories: ComponentCategory

    /// MUST be unowned(unsafe)
    var entity: Entity? { get set }

    init(entity: Entity, arguments: InitArguments) throws
}

private enum Placeholder<T> {
    case none, some(T)
}

extension Component {

    // This is an absolutely evil thing, It will absolutely corrupt everything that will try to read it :/
    fileprivate static var placeholder: Self {
        let space = Placeholder<Self>.none
        var value = unsafeBitCast(space, to: Self.self)
        value.entity = nil
        return value
    }

    var isValid: Bool { entity != nil }
}

protocol OpaqueComponentStorage {
    var type: OpaqueComponent.Type { get }
    func destroy(at index: Int) 
}

final class ComponentStorage<C: Component>: OpaqueComponentStorage {
    let type: OpaqueComponent.Type = C.self
    var buffer: [C] = []
    var category: [C.Categories: Range<Int>] = [:]

    private var freedIndicies: [Int] = []
    private var categoryFriedIndicies: [C.Categories: [Int]] = [:]


    func allocInit(for entity: Entity, with arguments: C.InitArguments) throws -> Int where C.Categories == Never {
        let new = try C.init(entity: entity, arguments: arguments)

        if let allocated = freedIndicies.popLast() {
            buffer[allocated] = new
            return allocated
        }

        buffer.append(new)
        return buffer.count - 1
    }

    func allocInit(for entity: Entity, category: C.Categories, with arguments: C.InitArguments) throws -> Int {
        let new = try C.init(entity: entity, arguments: arguments)
        
        if let allocated = categoryFriedIndicies[category]?.popLast() {
            buffer[allocated] = new
            return allocated
        }

        // At this point we know, that there is no free space in our category
        var categories = self.category
        categories[category] = categories[category] ?? 0..<1
        let sortedCategories = categories.sorted { $0.key < $1.key }
        let myIndex = sortedCategories.firstIndex { $0.key == category }!
        let newRange: Range<Int>
        switch myIndex {
        case 0 where sortedCategories.count - 1 == myIndex:
            newRange = 0..<2
        case 0:
            newRange = 0..<(1 + sortedCategories[1].value.lowerBound)
        case let index:
            newRange = sortedCategories[index].value.lowerBound..<(1 + sortedCategories[index].value.upperBound)
        }

        // At this point we know how will the new category look like, we shall insert it and move space
        self.category[category] = newRange
        if myIndex == sortedCategories.count - 1 {
            buffer.append(new)
            return buffer.count - 1
        } else {
            recursiveFree(fist: 1, category: sortedCategories[myIndex + 1].key)
            buffer[newRange.upperBound - 1] = new
            return newRange.upperBound - 1
        }
    }

    func initialize(categories: [C.Categories: Int], reserve tail: Int, addToExisting: Bool = false) {
        var spaceToInitialize: [C.Categories: Int] = categories
        if !addToExisting {
            for (category, space) in categories {
                spaceToInitialize[category] = max(
                    0,
                    space - (self.category[category]?.count ?? 0)
                )
            }
        }

        // Compute spatial properties
        let currentSpace = category.mapValues(\.count)
        let targetCategoriesSize = spaceToInitialize
                .merging(currentSpace) { $0 + $1 }
        let initializedSpace = targetCategoriesSize
                .reduce(0) { $0 + $1.value }

        // Reserve required space
        buffer.reserveCapacity(initializedSpace + tail)

        // Initialize required space
        buffer.append(contentsOf: Array(
            repeating: C.placeholder, 
            count: min(0, buffer.count - initializedSpace)
        ))

        // Start moving from behind
        let orderedCategories = targetCategoriesSize.sorted { $0.key > $1.key }
        var endIndex = buffer.count
        for (category, space) in orderedCategories { 
            let newRange = (endIndex - space - 1)..<endIndex
            endIndex = newRange.startIndex

            guard let currentSpace = self.category[category] else {
                self.category[category] = newRange
                continue
            }

            self.category[category] = newRange
            unsafeMove(range: currentSpace, toIndex: newRange.startIndex)
            defragment(category: category)
        }
        assert(endIndex == 0, "End index is not 0 at the end of enlarging")
    }

    func destroy(at index: Int) {
        if C.Categories.self == Never.self {
            freedIndicies.append(index)
        } else if let category = categoryOf(index: index) {
            categoryFriedIndicies[category, default: []].append(index)
        }

        buffer[index].destroy()
        buffer[index].entity = nil
    }

    func categoryOf(index: Int) -> C.Categories? {
        category.first { $1.contains(index) }?.key
    }

    private func recursiveFree(fist nItems: Int, category: C.Categories) {
        let sortedCategories = self.category.sorted { $0.key < $1.key }
        let myIndex = sortedCategories.firstIndex { $0.key == category }!
        let currentRange = sortedCategories[myIndex].value
        let requiredSpace = nItems 
            - (categoryFriedIndicies[category]?.count ?? 0)
            - currentRange.count
        
        // After this if, we assume that there is enough space to write to
        if requiredSpace > 0 {
            if myIndex < sortedCategories.count - 1 {
                recursiveFree(fist: requiredSpace, category: sortedCategories[myIndex + 1].key)
            } else {
                buffer.append(contentsOf: Array(repeating: C.placeholder, count: requiredSpace))
            }
        }

        let targetRange = (currentRange.lowerBound + nItems)..<(currentRange.upperBound + nItems)
        let additionalIndicies = Array(currentRange.upperBound..<targetRange.upperBound)
        var targetFreeIndicies = (categoryFriedIndicies[category] ?? []).filter { sortedCategories[myIndex].value.lowerBound + nItems > $0 } + additionalIndicies

        for i in currentRange.lowerBound..<targetRange.lowerBound where buffer[i].isValid {
            let newIndex = targetFreeIndicies.popLast()!
            buffer[newIndex] = buffer[i]
            buffer[newIndex].entity?.relocated(component: C.self, to: newIndex)
            buffer[i].entity = nil
        }

        self.category[category] = targetRange
        self.categoryFriedIndicies[category] = targetFreeIndicies
    }

    private func unsafeMove(range: Range<Int>, toIndex: Int) {
        for i in range {
            buffer[i + toIndex] = buffer[i]
        }
    }

    private func defragment(category: C.Categories) {
        guard let range = self.category[category] else {
            return
        }
        var firstFreeIndex: Int? = nil 

        for i in range {
            if !buffer[i].isValid {
                firstFreeIndex = min(firstFreeIndex ?? 0, i)
                continue
            }

            guard let freeIndex = firstFreeIndex else {
                continue
            }

            buffer[freeIndex] = buffer[i]
            buffer[freeIndex].entity?.relocated(component: C.self, to: freeIndex)
            buffer[i].entity = nil
            firstFreeIndex = firstFreeIndex.flatMap { $0 + 1 } ?? i
        }

        if let firstFreeIndex = firstFreeIndex, range.contains(firstFreeIndex) {
            categoryFriedIndicies[category] = Array(firstFreeIndex..<range.endIndex).reversed()
        } else {
            categoryFriedIndicies[category] = nil
        }
    }
}
