import SpriteKit

class TileMapNode: SKTileMapNode {
    private static let tileTexture = SKTexture(imageNamed: "block")
    private static let tileSize = CGSize(width: 32, height: 32)
    
    convenience init(columns: Int, rows: Int, tileSize: CGSize = TileMapNode.tileSize) {
        let tileDef   = SKTileDefinition(texture: TileMapNode.tileTexture, size: tileSize)
        let tileGroup = SKTileGroup(tileDefinition: tileDef)
        let tileSet   = SKTileSet(tileGroups: [tileGroup])
        
        self.init(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        
        self.anchorPoint = .zero
    }
    
    override func tileDefinition(atColumn column: Int, row: Int) -> SKTileDefinition? {
        self.tileSet.tileGroups.first?.rules.first?.tileDefinitions.first
    }
}
