import GameplayKit

class TileGridDrawComponent: GKComponent {
    fileprivate var gridEntity: TileGridEntity? {
        self.entity as? TileGridEntity
    }
    
    fileprivate func prepareToDraw() {
        gridEntity?.tiles.children.forEach {
            $0.removeFromParent()
        }
    }
    
    func draw() {
        guard let entity = gridEntity, let tiles = entity.tiles else {
            return
        }
        
        prepareToDraw()
        
        entity.grid.redraw(tiles) { sprite, value in
            if value == .clear {
                sprite.isHidden = true
            }
            else {
                sprite.isHidden = false
                sprite.color = value.color
                sprite.colorBlendFactor = value.colorBlendFactor
            }
        }
    }
}

class TileGridDrawGhostComponent: TileGridDrawComponent {
    override func draw() {
        guard let entity = gridEntity, let tiles = entity.tiles else {
            return
        }
        
        prepareToDraw()
        
        entity.grid.redraw(tiles) { sprite, value in
            guard UserDefaults.standard.bool(forKey: "ghostEnabled") else {
                sprite.isHidden = true
                return
            }
            
            if value == .clear {
                sprite.isHidden = true
            }
            else {
                sprite.isHidden = false
                sprite.color = value.color.withAlphaComponent(0.005)
                sprite.colorBlendFactor = 0.666
            }
        }
    }
}
