import SpriteKit
import GameplayKit

class GameScene: SKScene {
    static let nextPiecePosition: vector_float2 = [11, 15]
    static let gamePiecePosition: vector_float2 = [4, 18]
    
    private var gamestate: GameState!
    private var previousTime: TimeInterval = .infinity
    

    override func sceneDidLoad() {
        super.sceneDidLoad()
        self.gamestate = GameState(scene: self)
        self.gamestate.stateMachine.enter(GameState.ConfigureScene.self)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.gamestate.stateMachine.enter(GameState.GenerateNextPiece.self)
    }

    override func moveLeft(_ sender: Any?) {
        gamestate.nextMove = .left
    }
    
    override func moveRight(_ sender: Any?) {
        gamestate.nextMove = .right
    }
    
    override func moveDown(_ sender: Any?) {
        gamestate.nextMove = .down
    }
    
    override func moveUp(_ sender: Any?) {
        gamestate.stateMachine.enter(GameState.RotateGamePiece.self)
    }

    override func insertText(_ insertString: Any) {
        switch insertString as? String {
        case "w": moveUp(nil)
        case "a": moveLeft(nil)
        case "d": moveRight(nil)
        case "s": moveDown(nil)
        case "b":
            let isEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
            UserDefaults.standard.set(!isEnabled, forKey: "soundEnabled")
        case "g":
            let isEnabled = UserDefaults.standard.bool(forKey: "ghostEnabled")
            UserDefaults.standard.set(!isEnabled, forKey: "ghostEnabled")
        case " ":
            gamestate.stateMachine.enter(GameState.InsertGamePiece.self)
        default: ()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        self.interpretKeyEvents([event])
    }
    
    override func update(_ currentTime: TimeInterval) {
        if previousTime.isInfinite {
            previousTime = currentTime
        }
        
        gamestate.update(deltaTime: currentTime - previousTime)
        previousTime = currentTime
    }
}

enum DirectionKey: Int {
    case right
    case left
    case up
    case down
    
    init?(rawValue: Int) {
        switch rawValue {
        case NSUpArrowFunctionKey    : self = .up
        case NSDownArrowFunctionKey  : self = .down
        case NSLeftArrowFunctionKey  : self = .left
        case NSRightArrowFunctionKey : self = .right
        default                      : return nil
        }
    }
    
    init?(event: NSEvent) {
        guard let direction = event
            .characters?
            .flatMap ({ $0.unicodeScalars.map { Int($0.value) } })
            .compactMap(DirectionKey.init)
            .first else {
                return nil
        }
        self = direction
    }
}
