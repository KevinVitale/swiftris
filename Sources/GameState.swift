import GameplayKit

class GameState: GKEntity {
    // https://tetris.wiki/Scoring#Original_Nintendo_scoring_system
    enum LineMultiplier: Int {
        case single  = 1
        case double  = 2
        case triple  = 3
        case tetris  = 4
        
        private var pointValue: Int {
            switch self {
            case .single: return 40
            case .double: return 100
            case .triple: return 300
            case .tetris: return 1200
            }
        }
        
        func points(forLevel level: Int) -> Int {
            pointValue * (level + 1)
        }
    }
    
    required init(scene: GameScene) {
        super.init()
        self.scene = scene
        self.stateMachine = GKStateMachine(states: [
            BaseState(gameState: self),
            ConfigureScene(gameState: self),
            CountdownState(gameState: self),
            GenerateNextPiece(gameState: self),
            InsertGamePiece(gameState: self),
            MoveGamePiece(gameState: self),
            RotateGamePiece(gameState: self)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // https://gaming.stackexchange.com/a/13129
    fileprivate var levelSpeed: TimeInterval {
        switch currentLevel {
        case 0...9:
            return Double(48 - (5 * currentLevel)) / 60.0
        case 10...12:
            return 5 / 60
        case 13...15:
            return 4 / 60
        case 16...18:
            return 3 / 60
        case 19...28:
            return 2 / 60
        default:
            return 1 / 60
        }
    }
    
    private var scene: GameScene!
    
    private var gameScore = 0 {
        didSet {
            scoreboard?.setScore(.score(gameScore))
        }
    }
    
    private var currentLevel: Int {
        linesCleared / 10
    }
    
    private var linesCleared = 0 {
        didSet {
            scoreboard?.setScore(.lines(linesCleared))
            scoreboard?.setScore(.level(currentLevel))
        }
    }
    
    private(set) var gameboard  = TileGridEntity(layout: .grid(columns: 10, rows: 22))
    private(set) var gamepiece  = TileGridEntity(layout: .random())
    private(set) var nextpiece  = TileGridEntity(layout: .random())
    private(set) var ghostpiece = TileGridEntity(layout: .random())
    
    private(set) var stateMachine: GKStateMachine! = nil

    private var scoreboard: ScoreboardNode? {
        scene.children.first as? ScoreboardNode
    }
    
    var nextMove: DirectionKey? = nil {
        didSet {
            guard nextMove != nil else {
                return
            }
            stateMachine.enter(MoveGamePiece.self)
        }
    }

    fileprivate func drop(piece: TileGridEntity) {
        repeat {
            /* no-op */
        } while piece.move(inDirection: .down, within: gameboard)
    }
    
    func didClear(lines multiplier: LineMultiplier) {
        self.gameScore += multiplier.points(forLevel: currentLevel)
        self.linesCleared += multiplier.rawValue
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        stateMachine.update(deltaTime: seconds)
    }
}

extension GameState {
    class BaseState: GKState {
        required init(gameState: GameState) {
            self.state = gameState
            super.init()
        }
        
        let state: GameState
    }
}

extension GameState {
    class CountdownState: BaseState {
        private var countdown: TimeInterval = .infinity

        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            
            switch previousState.self {
            case is MoveGamePiece   : ()
            case is RotateGamePiece : ()
            default                 : self.countdown = state.levelSpeed
            }
        }
        
        override func update(deltaTime seconds: TimeInterval) {
            super.update(deltaTime: seconds)
            self.countdown -= seconds
            
            if countdown < 0 {
                countdown += state.levelSpeed
                state.nextMove = .down
            }
        }
    }
}
    
extension GameState {
    class ConfigureScene: BaseState {
        func configure(scene: GameScene) {
            state.gameboard.tiles.removeFromParent()
            state.gamepiece.tiles.removeFromParent()
            state.nextpiece.tiles.removeFromParent()
            state.ghostpiece.tiles.removeFromParent()
            
            state.scene.addChild(ScoreboardNode(forScene: scene))
            state.scene.addChild(state.gameboard.tiles)
            state.scene.addChild(state.gamepiece.tiles)
            state.scene.addChild(state.nextpiece.tiles)
            state.scene.addChild(state.ghostpiece.tiles)
            
            state.gamepiece.addComponent(TileGridMovableComponent())
            state.ghostpiece.addComponent(TileGridMovableComponent())
            
            state.gameboard.addComponent(TileGridDrawComponent())
            state.nextpiece.addComponent(TileGridDrawComponent())
            state.gamepiece.addComponent(TileGridDrawComponent())
            state.ghostpiece.addComponent(TileGridDrawGhostComponent())
            
            
            state.gameboard.position = .zero // Forces a re-draw
            state.nextpiece.position = GameScene.nextPiecePosition
        }
        
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            self.configure(scene: self.state.scene)
        }
    }
}

extension GameState {
    class GenerateNextPiece: BaseState {
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            
            // Swap grid layout and reposition
            state.gamepiece.grid     = state.nextpiece.grid
            state.gamepiece.position = GameScene.gamePiecePosition
            
            // Copy grid layout and reposition
            state.ghostpiece.grid      = state.gamepiece.grid
            state.ghostpiece.position = state.gamepiece.position
            
            // Send to bottom of gameboard
            state.drop(piece: state.ghostpiece)
            
            // Generate the next layout
            state.nextpiece.grid = GridLayout.random().createGrid()
            
            stateMachine?.enter(CountdownState.self)
        }
    }
}

extension GameState {
    class InsertGamePiece: BaseState {
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            state.drop(piece: state.gamepiece)
            state.gameboard.apply(tileGridEntity: state.gamepiece)
            
            let completedRows = state.gameboard.grid.removeCompletedRows()
            if let lines = GameState.LineMultiplier(rawValue: completedRows.count) {
                state.didClear(lines: lines)
            }
            
            stateMachine?.enter(GenerateNextPiece.self)
        }
    }
}

extension GameState {
    class MoveGamePiece: BaseState {
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            if let nextMove = state.nextMove, state.gamepiece.move(inDirection: nextMove, within: state.gameboard) {
                defer { state.nextMove = nil }
                state.gamepiece.playSound()
                
                state.ghostpiece.position = state.gamepiece.position
                state.drop(piece: state.ghostpiece)
            }
            
            switch previousState.self {
            case is CountdownState:
                stateMachine?.enter(type(of: previousState!))
            default:
                stateMachine?.enter(BaseState.self)
            }
        }
    }
}

extension GameState {
    class RotateGamePiece: BaseState {
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            if state.gamepiece.move(inDirection: .up, within: state.gameboard) {
                self.state.gamepiece.playSound()
            }
            state.ghostpiece.grid = state.gamepiece.grid
            state.ghostpiece.position = state.gamepiece.position
            state.drop(piece: state.ghostpiece)
            
            switch previousState.self {
            case is CountdownState:
                stateMachine?.enter(type(of: previousState!))
            default:
                stateMachine?.enter(BaseState.self)
            }
        }
    }
}

