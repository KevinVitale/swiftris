import SpriteKit

enum TileColor: UInt8 {
    case unknown = 255
    case empty   = 254
    case clear   = 0
    case blue    = 1
    case yellow  = 2
    case green   = 3
    case red     = 4
    case magenta = 5
    case cyan    = 6
    case brown   = 7
    
    var color: SKColor {
        switch self {
        //-------------------------------//
        case .blue   :return .blue
        case .yellow :return .yellow
        case .green  :return .green
        case .red    :return .red
        case .magenta:return .magenta
        case .cyan   :return .cyan
        case .brown  :return .brown
        //-------------------------------//
        case .empty  :return .clear
        case .clear  :return .clear
        //-------------------------------//
        default      :return .black
        }
    }
    
    var colorBlendFactor: CGFloat {
        switch self {
        case .empty  :return 0.5
        case .clear  :return 1.0
        case .blue   :return 0.5
        case .yellow :return 0.5
        case .green  :return 0.5
        case .red    :return 0.5
        case .magenta:return 0.5
        case .cyan   :return 0.5
        case .brown  :return 0.5
        default      :return 0.0
        }
    }
    
    var isOpen: Bool {
        switch self {
        case .empty: return true
        case .clear: return true
        default: return false
        }
    }
    
    private static let tileColors: [TileColor] = [
        .blue, .yellow, .green, .red, .magenta, .cyan, .brown
    ]
    
    static func randomColor() -> TileColor {
        TileColor.tileColors.randomElement() ?? .unknown
    }
}

extension TileColor: Numeric {
    init?<T>(exactly source: T) where T : BinaryInteger {
        switch source {
        case 254:self = .empty
        case 0  :self = .clear
        case 1  :self = .blue
        case 2  :self = .yellow
        case 3  :self = .green
        case 4  :self = .red
        case 5  :self = .magenta
        case 6  :self = .cyan
        case 7  :self = .brown
        default :self = .unknown
        }
    }
    
    init(integerLiteral value: TileColor.RawValue.IntegerLiteralType) {
        self.init(exactly: value)!
    }
    
    var magnitude: UInt8.Magnitude {
        rawValue.magnitude
    }
    
    static func *  (lhs: TileColor, rhs: TileColor) -> TileColor { .unknown }
    static func *= (lhs: inout TileColor, rhs: TileColor) { }
    static func += (lhs: inout TileColor, rhs: TileColor) { }
    static func -= (lhs: inout TileColor, rhs: TileColor) { }
    static func -  (lhs: TileColor, rhs: TileColor) -> TileColor { .unknown }
    static func +  (lhs: TileColor, rhs: TileColor) -> TileColor { .unknown }
    
    typealias Magnitude = RawValue.Magnitude
    typealias IntegerLiteralType = RawValue.IntegerLiteralType
}
