import SpriteKit
import GameplayKit

class TileGridEntity: GKEntity {
    init(grid: Grid<TileColor>) {
        super.init()
        self.tiles = TileMapNode(columns: grid.columns, rows: grid.rows)
        self.grid = grid
    }

    convenience init(layout: GridLayout) {
        self.init(grid: layout.createGrid())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var tiles: TileMapNode!
    
    private var drawComponent: TileGridDrawComponent? {
        if let component = self.component(ofType: TileGridDrawGhostComponent.self) {
            return component
        }
        else {
            return self.component(ofType: TileGridDrawComponent.self)
        }
    }
    
    var grid: Grid<TileColor> = Grid() {
        didSet {
            self.redraw()
        }
    }

    var position: vector_float2 = .zero {
        didSet {
            self.redraw()
            
            let newX = CGFloat(position.x) * self.tiles.tileSize.width
            let newY = CGFloat(position.y) * self.tiles.tileSize.height
            self.tiles.position = CGPoint(x: newX, y: newY)
        }
    }
    
    private func calculateLayoutFrame() -> CGRect {
        let width: CGFloat = CGFloat(grid.firstEmptyColumn) * tiles.tileSize.width
        let height: CGFloat = CGFloat(grid.firstEmptyRow) * tiles.tileSize.height
        
        return CGRect(origin: self.tiles.frame.origin, size: CGSize(width: width, height: height))
    }

    func redraw() {
        drawComponent?.draw()
    }
    
    func move(inDirection direction: DirectionKey, within otherGrid: TileGridEntity) -> Bool {
        let moveComponent = component(ofType: TileGridMovableComponent.self)
        return moveComponent?.move(inDirection: direction, within: otherGrid) ?? false
    }
    
    func playSound() {
        let moveComponent = component(ofType: TileGridMovableComponent.self)
        moveComponent?.playSound()
    }

    func rotate() {
        self.grid.rotate(.counterClockwise)
    }

    func apply(tileGridEntity: TileGridEntity?) {
        guard let tileGridEntity = tileGridEntity else {
            return
        }
        
        guard self.contains(tileGridEntity: tileGridEntity) else {
            return
        }
        
        let x = Int(tileGridEntity.position.x)
        let y = Int(tileGridEntity.position.y)
        
        var this = self.grid
        let that = tileGridEntity.grid
        
        for row in 0..<that.rows {
            for col in 0..<that.columns {
                let thatValue = that[col, row]
                guard thatValue.isOpen == false else {
                    continue
                }
                
                let offsetX = col + x
                let offsetY = row + y
                
                this[offsetX, offsetY] = thatValue
            }
        }
        
        self.grid = this
    }

    func collides(withTileGridEntity tileGridEntity: TileGridEntity?) -> Bool {
        guard let tileGridEntity = tileGridEntity else {
            return false
        }
        
        guard self.contains(tileGridEntity: tileGridEntity) else {
            return true
        }
        
        let x = Int(tileGridEntity.position.x)
        let y = Int(tileGridEntity.position.y)

        let this = self.grid
        let that = tileGridEntity.grid

        for row in 0..<that.rows {
            for col in 0..<that.columns {
                let thatValue = that[col, row]
                guard thatValue.isOpen == false else {
                    continue
                }
                
                let offsetX = col + x
                let offsetY = row + y
                
                let thisValue = this[offsetX, offsetY]

                guard thisValue.isOpen != thatValue.isOpen else {
                    return true
                }
            }
        }

        return false
    }

    func contains(tileGridEntity: TileGridEntity) -> Bool {
        self.tiles.calculateAccumulatedFrame().contains(tileGridEntity.calculateLayoutFrame())
    }
    
    func containedIn(tileGridEntity: TileGridEntity) -> Bool {
        tileGridEntity.contains(tileGridEntity: self)
    }
}

enum GridLayout {
    case grid(columns: Int, rows: Int)
    case square
    case leftHook
    case rightHook
    case long
    case rightZag
    case leftZag
    case cross
    case unknown
    
    private static let layouts: [GridLayout] = [
        square, leftHook, rightHook, long, rightZag, leftZag, cross
    ]
    
    private var tileColor: TileColor {
        switch self {
        //-------------------------------//
        case .square    : return .blue
        case .leftHook  : return .green
        case .rightHook : return .yellow
        case .long      : return .red
        case .rightZag  : return .brown
        case .leftZag   : return .cyan
        case .cross     : return .magenta
        //-------------------------------//
        case .grid      : return .empty
        case .unknown   : return .clear
        //-------------------------------//
        }
    }
    
    func createGrid() -> Grid<TileColor> {
        switch self {
        case .grid(let columns, let rows):
            return Grid(rows: rows, columns: columns, defaultValue: .empty)
        case .square:
            var grid = Grid<TileColor>(rows: 4, columns: 4, defaultValue: .clear)
            grid[0,0] = self.tileColor
            grid[0,1] = self.tileColor
            grid[1,0] = self.tileColor
            grid[1,1] = self.tileColor
            return grid
        case .leftZag:
            var grid = Grid<TileColor>(rows: 4, columns: 4, defaultValue: .clear)
            grid[0,0] = self.tileColor
            grid[1,0] = self.tileColor
            grid[1,1] = self.tileColor
            grid[2,1] = self.tileColor
            return grid
        case .rightZag:
            var grid = Grid<TileColor>(rows: 4, columns: 4, defaultValue: .clear)
            grid[0,1] = self.tileColor
            grid[1,1] = self.tileColor
            grid[1,0] = self.tileColor
            grid[2,0] = self.tileColor
            return grid
        case .cross:
            var grid = Grid<TileColor>(rows: 4, columns: 4, defaultValue: .clear)
            grid[0,0] = self.tileColor
            grid[1,0] = self.tileColor
            grid[1,1] = self.tileColor
            grid[2,0] = self.tileColor
            return grid
        case .long:
            var grid = Grid<TileColor>(rows: 4, columns: 4, defaultValue: .clear)
            grid[0,0] = self.tileColor
            grid[1,0] = self.tileColor
            grid[2,0] = self.tileColor
            grid[3,0] = self.tileColor
            return grid
        case .leftHook:
            var grid = Grid<TileColor>(rows: 4, columns: 4, defaultValue: .clear)
            grid[0,0] = self.tileColor
            grid[1,0] = self.tileColor
            grid[2,0] = self.tileColor
            grid[2,1] = self.tileColor
            return grid
        case .rightHook:
            var grid = Grid<TileColor>(rows: 4, columns: 4, defaultValue: .clear)
            grid[0,0] = self.tileColor
            grid[1,0] = self.tileColor
            grid[2,0] = self.tileColor
            grid[0,1] = self.tileColor
            return grid
        default:
            return Grid<TileColor>(rows: 4, columns: 4, defaultValue: .clear)
        }
    }
    
    private static let randomDistribution = GKShuffledDistribution(lowestValue: 0, highestValue: GridLayout.layouts.count - 1)

    static func random() -> GridLayout {
        GridLayout.layouts[randomDistribution.nextInt()]
    }
}

class TileGridMovableComponent: GKComponent {
    private var gridEntity: TileGridEntity? {
        self.entity as? TileGridEntity
    }
    
    private func undoCommand() -> () -> () {
        guard let entity = self.gridEntity else {
            return { /* no-op */ }
        }
        
        let position = entity.position
        let grid = entity.grid
        return {
            entity.position = position
            entity.grid = grid
        }
    }
    
    fileprivate func playSound() {
        if UserDefaults.standard.bool(forKey: "soundEnabled") {
            gridEntity?.tiles.run(SKAction.playSoundFileNamed("blip.caf", waitForCompletion: false))
        }
    }
    
    @discardableResult
    fileprivate func move(inDirection direction: DirectionKey, within tileGridEntity: TileGridEntity) -> Bool {
        let revert = undoCommand()
        
        switch direction {
        case .up    : gridEntity?.rotate()
        case .down  : gridEntity?.position -= [0, 1]
        case .left  : gridEntity?.position -= [1, 0]
        case .right : gridEntity?.position += [1, 0]
        }

        if tileGridEntity.collides(withTileGridEntity: gridEntity) {
            revert()
            return false
        }
        else {
            return true
        }
    }
}

