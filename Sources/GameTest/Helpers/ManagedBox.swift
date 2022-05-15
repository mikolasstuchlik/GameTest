import CLibs

@propertyWrapper
final class ManagedBox<T> {
    var wrappedValue: T {
        get { mutable.pointee }
        set { mutable.initialize(to: newValue) }
    }
    var mutable: UnsafeMutablePointer<T>
    var immutable: UnsafePointer<T> { UnsafePointer(mutable) } 

    init(wrappedValue: T) {
        mutable = UnsafeMutablePointer<T>.allocate(capacity: 1)
        mutable.initialize(to: wrappedValue)
    }

    deinit {
        mutable.deallocate()
    }
}
