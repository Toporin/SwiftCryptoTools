import Foundation

public struct HsExtension<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol IHsExtension {
    associatedtype AnyType
    var hs: AnyType { get }
}

public extension IHsExtension {
    /// Gets a namespace holder for HS compatible types.
    var hs: HsExtension<Self> {
        get { HsExtension(self) }
    }
}
