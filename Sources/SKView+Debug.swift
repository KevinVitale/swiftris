import SpriteKit

extension SKView {
    /// Describes the debug flags available for `SKView`.
    public struct DebugFlag: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        static let fps        = DebugFlag(rawValue: 1 << 0)
        static let physics    = DebugFlag(rawValue: 1 << 1)
        static let fields     = DebugFlag(rawValue: 1 << 2)
        static let quadCount  = DebugFlag(rawValue: 1 << 3)
        static let drawCount  = DebugFlag(rawValue: 1 << 4)
        static let nodeCount  = DebugFlag(rawValue: 1 << 5)
    }
    
    /// Toggle arbitruary debug flags.
    ///
    /// - Parameters:
    ///     - flags: An option set containing debug flags.
    public func toggle(debug flags: DebugFlag) {
        showsFPS       = flags.contains(.fps)
        showsFields    = flags.contains(.fields)
        showsPhysics   = flags.contains(.physics)
        showsDrawCount = flags.contains(.drawCount)
        showsNodeCount = flags.contains(.nodeCount)
        showsQuadCount = flags.contains(.quadCount)
    }
}
