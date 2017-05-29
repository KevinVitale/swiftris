import SpriteKit
import GameKit

/**
 */
enum Piece {
    case square(CGPoint)
    case leftHook(CGPoint)
    case rightHook(CGPoint)
    case long(CGPoint)
    case rightZag(CGPoint)
    case leftZag(CGPoint)
    case cross(CGPoint)

    ///
    var position: CGPoint {
        switch(self) {
        case    .square(let position): return position
        case  .leftHook(let position): return position
        case .rightHook(let position): return position
        case      .long(let position): return position
        case  .rightZag(let position): return position
        case   .leftZag(let position): return position
        case     .cross(let position): return position
        }
    }

    ///
    var preferredTileColor: SKTileMapNode.TileColor {
        switch(self) {
        case    .square: return .blue
        case  .leftHook: return .green
        case .rightHook: return .yellow
        case      .long: return .red
        case  .rightZag: return .cyan
        case   .leftZag: return .brown
        case     .cross: return .magenta
        }
    }

    /**
     */
    func position(at point: CGPoint) -> Piece {
        switch(self) {
        case    .square: return .square(point)
        case  .leftHook: return .leftHook(point)
        case .rightHook: return .rightHook(point)
        case      .long: return .long(point)
        case  .rightZag: return .rightZag(point)
        case   .leftZag: return .leftZag(point)
        case     .cross: return .cross(point)
        }
    }

    /**
     */
    func defaultArray(tileColor: SKTileMapNode.TileColor) -> [[SKTileMapNode.TileColor.RawValue]] {
        let rawValue = tileColor.rawValue
        switch(self) {
        case .square:
            return [
                [rawValue, rawValue]
              , [rawValue, rawValue]
            ]
        case .leftHook:
            return [
                [0       , 0       , rawValue]
              , [rawValue, rawValue, rawValue]
            ]
        case .rightHook:
            return [
                [rawValue, rawValue, rawValue]
              , [0       , 0       , rawValue]
            ]
        case .long:
            return [
                [rawValue]
              , [rawValue]
              , [rawValue]
              , [rawValue]
            ]
        case .leftZag:
            return [
                [rawValue, rawValue, 0]
              , [0       , rawValue, rawValue]
            ]
        case .rightZag:
            return [
                [0,        rawValue, rawValue]
              , [rawValue, rawValue, 0]
            ]
        case .cross:
            return [
                [rawValue]
              , [rawValue, rawValue]
              , [rawValue]
            ]
        }
    }

    ///
    private static let pieceTypes: [Piece] = [
        .square(.zero)
      , .leftHook(.zero)
      , .rightHook(.zero)
      , .long(.zero)
      , .rightZag(.zero)
      , .leftZag(.zero)
      , .cross(.zero)
    ]
    
    ///
    static let randomDistribution = GKRandomDistribution(lowestValue: 1, highestValue: Piece.pieceTypes.count)

    /**
     */
    static func random(at position: CGPoint = .zero, randomDistribution: GKRandomDistribution = Piece.randomDistribution) -> Piece {
        switch(randomDistribution.nextInt()) {
        case 1: return .square(position)
        case 2: return .leftHook(position)
        case 3: return .rightHook(position)
        case 4: return .long(position)
        case 5: return .rightZag(position)
        case 6: return .leftZag(position)
        case 7: return .cross(position)
        default: fatalError("Invalid random piece generation")
        }
    }
}
