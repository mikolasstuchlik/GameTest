protocol ComponentCategory: Hashable, Comparable {}

protocol CategoryComponent: Component {
    associatedtype Categories: ComponentCategory

    static var placeholder: Self { get }
}

final class CategoryVectorStorage<C: CategoryComponent>: ComponentStore {
    typealias StoreOptions = C.Categories
    typealias ComponentIdentifier = Int
    typealias StoredComponent = C

    let type: OpaqueComponent.Type = C.self
    var buffer: [C] = []
    var category: [C.Categories: Range<Int>] = [:]

    private var categoryFriedIndicies: [C.Categories: [Int]] = [:]

    func allocInit(for entity: Entity, options: StoreOptions, with arguments: StoredComponent.InitArguments) throws -> ComponentIdentifier {
        let new = try C.init(entity: entity, arguments: arguments)
        
        if let allocated = categoryFriedIndicies[options]?.popLast() {
            buffer[allocated] = new
            return allocated
        }

        // At this point we know, that there is no free space in our category
        var categories = self.category
        categories[options] = categories[options] ?? 0..<0
        let sortedCategories = categories.sorted { $0.key < $1.key }
        let myIndex = sortedCategories.firstIndex { $0.key == options }!
        let newRange: Range<Int>
        switch myIndex {
        case 0 where sortedCategories.count == 1:
            newRange = 0..<(1 + sortedCategories[0].value.upperBound)
        case 0:
            newRange = 0..<(1 + sortedCategories[1].value.lowerBound)
        case let index:
            newRange = sortedCategories[index - 1].value.upperBound..<(
                1 
                + sortedCategories[index - 1].value.upperBound
                + sortedCategories[index].value.count
            )
        }

        // At this point we know how will the new category look like, we shall insert it and move space
        self.category[options] = newRange
        if myIndex == sortedCategories.count - 1 {
            buffer.append(new)
            return buffer.count - 1
        } else {
            recursiveFree(fist: 1, category: sortedCategories[myIndex + 1].key)
            buffer[newRange.upperBound - 1] = new
            return newRange.upperBound - 1
        }
    }

    func access<R>(at identifier: inout OpaqueComponentIdentifier, validityScope: (inout StoredComponent) throws -> R) rethrows -> R? {
        try validityScope(&buffer[identifier as! ComponentIdentifier])
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
            count: max(0, initializedSpace - buffer.count)
        ))

        // Start moving from behind
        let orderedCategories = targetCategoriesSize.sorted { $0.key > $1.key }
        var endIndex = buffer.count
        for (category, space) in orderedCategories { 
            let newRange = (endIndex - space)..<(endIndex)
            endIndex = newRange.startIndex

            guard let currentSpace = self.category[category] else {
                self.category[category] = newRange
                self.categoryFriedIndicies[category] = Array(newRange)
                continue
            }

            self.category[category] = newRange
            unsafeMove(range: currentSpace, toIndex: newRange.startIndex)
            defragment(category: category, updateAllLocations: true)
        }
        assert(endIndex == 0, "End index is not 0 at the end of enlarging")
    }

    func destroy(at index: Int) {
        if let category = categoryOf(index: index) {
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
        let freeIndicies = categoryFriedIndicies[category] ?? []
        let freeIndiciesInResignedSpace = freeIndicies.filter { $0 < currentRange.lowerBound + nItems }
        let numberOfDisplacedItems = (currentRange.lowerBound..<(currentRange.lowerBound + nItems)).count - freeIndiciesInResignedSpace.count
        let requiredSpace = numberOfDisplacedItems
            - (freeIndicies.count - freeIndiciesInResignedSpace.count)
            
             

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
        var targetFreeIndicies = freeIndicies.filter { currentRange.lowerBound + nItems >= $0 } + additionalIndicies

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

    private func defragment(category: C.Categories, updateAllLocations: Bool = false) {
        guard let range = self.category[category] else {
            return
        }
        var firstFreeIndex: Int? = nil 

        for i in range {
            if !buffer[i].isValid {
                firstFreeIndex = min(firstFreeIndex ?? i, i)
                continue
            }

            guard let freeIndex = firstFreeIndex else {
                if updateAllLocations {
                    buffer[i].entity?.relocated(component: C.self, to: i)
                }
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