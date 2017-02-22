import SpriteKit
import GameKit

///
fileprivate let Tile = SKTexture(imageNamed: "block")
fileprivate let TileDefinition = SKTileDefinition(texture: Tile)
fileprivate let TileGroup = SKTileGroup(tileDefinition: TileDefinition)
fileprivate let TileSet = SKTileSet(tileGroups: [TileGroup, .empty()])

/**
 */
extension SKTileMapNode {
    /**
     */
    convenience init(_ dimensions: (rows: Int, columns: Int)) {
        self.init(tileSet: TileSet, columns: dimensions.columns, rows: dimensions.rows, tileSize: Tile.size())
        self.anchorPoint = .zero
    }
}

/**
 */
extension SKTileMapNode {
    /**
     */
    enum TileColor: Int {
        case  clear = 0
        case   blue = 1
        case  green
        case yellow
        case    red
        case   cyan
        case  brown
        case  magenta

        ///
        weak var color: SKColor! {
            switch (self) {
            case  .clear: return .clear
            case   .blue: return .blue
            case  .green: return .green
            case .yellow: return .yellow
            case    .red: return .red
            case   .cyan: return .cyan
            case  .brown: return .brown
            case .magenta:return .magenta
            }
        }

        ///
        private static let randomDistribution = GKRandomDistribution(lowestValue: 1, highestValue: TileColor.tileColors.count)
        
        ///
        private static let tileColors: [TileColor] = [
            .blue
          , .green
          , .yellow
          , .red
          , .cyan
          , .brown
          , .magenta
        ]
    
        /**
         */
        static func random() -> TileColor {
            return randomDistribution.nextInt().tileColor
        }
    }
}

/**
 */
extension Int {
    ///
    var tileColor: SKTileMapNode.TileColor {
        return SKTileMapNode.TileColor(rawValue: self) ?? .brown
    }

    static let   blueTile = SKTileMapNode.TileColor.blue.rawValue
    static let  greenTile = SKTileMapNode.TileColor.green.rawValue
    static let yellowTile = SKTileMapNode.TileColor.yellow.rawValue
    static let    redTile = SKTileMapNode.TileColor.red.rawValue
    static let   cyanTile = SKTileMapNode.TileColor.cyan.rawValue
    static let  brownTile = SKTileMapNode.TileColor.brown.rawValue
    static let  clearTile = SKTileMapNode.TileColor.clear.rawValue
}

/**
 */
extension SKTileMapNode {
    /**
     */
    func render(tiles values: [[Int]], texture: SKTexture, skipEmpty: Bool = true) {
        /// 🔄 Loop
        for row in 0..<numberOfRows {
            /// 🔄 Loop
            for column in 0..<numberOfColumns {
                /// - parameter tileCenter: The center point for the current tile.
                let tileCenter = self.centerOfTile(atColumn: column, row: row)

                /// - parameter tileSprite: The sprite located at `tileCenter`.
                var tileSprite: SKSpriteNode! = self.nodes(at: tileCenter)
                    .flatMap { $0 as? SKSpriteNode }
                    .first

                /// - note: Check for existing sprite
                if (tileSprite == nil) {
                    /// Create a new sprite node.
                    tileSprite = SKSpriteNode(texture: texture)

                    /// Setup tile
                    tileSprite.position = tileCenter

                    /// Add it to `self`.
                    addChild(tileSprite)
                }

                /// - note: Default tile color
                tileSprite.color = 0.tileColor.color
                tileSprite.colorBlendFactor = 1.0

                /// - note: Determine appearance
                if row < values.endIndex && column < values[row].endIndex {
                    ///
                    let value = values[row][column]

                    ///
                    tileSprite.color = value.tileColor.color

                    ///
                    if value > 0 || !skipEmpty {
                        tileSprite.colorBlendFactor = 0.5
                    }
                }
            }
        }
    }
}
