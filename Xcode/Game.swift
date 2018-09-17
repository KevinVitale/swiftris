import SpriteKit
import GameKit

/**
 */
final class Game {
    //--------------------------------------------------------------------------
    // GameState
    //--------------------------------------------------------------------------
    private class GameState: GKState {
        ///
        weak var gameScene: GameScene? = nil

        ///
        weak var game: Game! {
            return gameScene?.game
        }
        
        /**
         */
        required init(gameScene: GameScene) {
            super.init()
            self.gameScene = gameScene
        }
    }
    //--------------------------------------------------------------------------
    // Initialize
    //--------------------------------------------------------------------------
    private final class Initialize: GameState {
        /**
         */
        override func didEnter(from previousState: GKState?) {
            defer { game.stateMachine.enter(InsertPiece.self) }
            game.reset()
        }
    }
    //--------------------------------------------------------------------------
    // Drop Piece
    //--------------------------------------------------------------------------
    private final class DropPiece: GameState {
        ///
        private var accum: TimeInterval = 0.0

        /**
         */
        override func didEnter(from previousState: GKState?) {
            accum = 0.0
        }

        /**
         */
        override func update(deltaTime seconds: TimeInterval) {
            ///
            accum += seconds
            
            ///
            if accum >= game.fallingTime {
                accum -= game.fallingTime

                ///
                if !game.player.move(.down, scene: gameScene) {
                    game.checkCollisions()
                }
            }
        }
    }
    //--------------------------------------------------------------------------
    // Insert Piece
    //--------------------------------------------------------------------------
    private final class InsertPiece: GameState {
        /**
         */
        override func didEnter(from previousState: GKState?) {
            defer { stateMachine?.enter(DropPiece.self) }

            ///
            game.player.generateNextPiece(in: game.boardDimensions, pieceDimension: game.previewDimensions)

            ///
            let (nextPiece, tileColor) = game.player.nextPiece

            ///
            guard let previewPiece = nextPiece?.defaultArray(tileColor: tileColor) else {
                return
            }

            ///
            game.previewBoard = previewPiece
        }

        /**
         */
        override func willExit(to nextState: GKState) {
            let piecePosition = game.player.currentPiece.piece?.position ?? .zero
            let pieceTiles = game.player.currentPiece.tiles
            game.render?(.piece(position: piecePosition, tiles: pieceTiles))
        }
    }
    //--------------------------------------------------------------------------
    // Apply Collisions
    //--------------------------------------------------------------------------
    private final class ApplyCollisions: GameState {
        /**
         */
        override func didEnter(from previousState: GKState?) {
            ///
            var transitionToNextState = { [weak self] in
                self?.stateMachine?.enter(InsertPiece.self)
            }

            ///
            defer { _ = transitionToNextState() }

            ///
            guard let piece = game.player.currentPiece.piece
                , let gameBoardNode = gameScene?.gameBoardNode else {
                    return
            }

            ///
            var gameBoard = game.gameBoard
            let tiles = game.player.currentPiece.tiles

            ///
            let tileRow = gameBoardNode.tileRowIndex(fromPosition: piece.position)
            let tileColumn = gameBoardNode.tileColumnIndex(fromPosition: piece.position)

            ///
            guard tileRow < (gameBoardNode.numberOfRows - tiles.count) else {
                ///
                transitionToNextState = { [weak self] in
                    self?.stateMachine!.enter(GameOver.self)
                }
                
                ///
                return
            }

            ///
            for (row, array) in tiles.lazy.enumerated() {
                ///
                let rowIndex = row.advanced(by: tileRow)
                
                /// Indexes above `number can be ignored
                guard rowIndex < gameBoardNode.numberOfRows else {
                    break
                }
                
                /// Indexes below `0` fail
                guard rowIndex >= 0 else {
                    return
                }
                
                ///
                let rowTiles = gameBoard[rowIndex].lazy
                
                ///
                for (column, value) in array.lazy.enumerated() {
                    ///
                    let columnIndex = column.advanced(by: tileColumn)
                    
                    ///
                    if columnIndex >= 0, columnIndex < gameBoardNode.numberOfColumns, rowTiles[columnIndex] == 0 {
                        gameBoard[rowIndex][columnIndex] = value
                    }
                }
            }

            ///
            var index = gameBoard.startIndex
            var rowsDropped: Int = 0
            while index < gameBoard.endIndex {
                if !(gameBoard[index]).contains(0) {
                    rowsDropped = rowsDropped.advanced(by: 1)
                    gameBoard.remove(at: index)
                    gameBoard.append([Int](repeating: 0, count: game!.boardDimensions.columns))
                } else {
                    index = gameBoard.index(after: index)
                }
            }

            ///
            if rowsDropped > 0, let lineMultiplier = GameScore.LineMultiplier(rawValue: rowsDropped) {
                game.score = game.score + lineMultiplier
            }

            ///
            game.gameBoard = gameBoard
        }
    }
    //--------------------------------------------------------------------------
    // Game Over
    //--------------------------------------------------------------------------
    private final class GameOver: GameState {
        /**
         */
        override func didEnter(from previousState: GKState?) {
            let gameScene = self.gameScene!

            ///
            gameScene.gameOverScene.isHidden = false
            gameScene.gameOverLabel.isHidden = false

            ///
            gameScene.gameBoardNode?.move(toParent: gameScene.gameOverScene)
            gameScene.currentPieceNode?.move(toParent: gameScene.gameOverScene)
            gameScene.previewPieceNode?.move(toParent: gameScene.gameOverScene)
        }

        /**
         */
        override func willExit(to nextState: GKState) {
            let gameScene = self.gameScene!

            ///
            gameScene.gameBoardNode?.move(toParent: gameScene)
            gameScene.currentPieceNode?.move(toParent: gameScene)
            gameScene.previewPieceNode?.move(toParent: gameScene)

            ///
            gameScene.gameOverScene.isHidden = true
            gameScene.gameOverLabel.isHidden = true
        }
    }
    //--------------------------------------------------------------------------

    /**
     */
    enum TileBoard {
        case board([[Int]])
        case piece(position: CGPoint, tiles: [[Int]])
        case preview([[Int]])
        case score(GameScore)
    }

    ///
    private(set) var player = Player()
    
    ///
    private(set) var gameBoard: [[Int]] = [[Int]]() {
        didSet {
            render?(.board(gameBoard))
        }
    }

    ///
    private var previewBoard: [[Int]] = [[Int]]() {
        didSet {
            render?(.preview(previewBoard))
        }
    }

    ///
    private let boardDimensions: (rows: Int, columns: Int)

    ///
    private let previewDimensions: (rows: Int, columns: Int)

    ///
    private(set) var score: GameScore = GameScore() {
        didSet {
            render?(.score(score))
        }
    }

    ///
    private var fallingTime: TimeInterval {
        ///
        let defaultFallSpeed: TimeInterval = 1500.0
        let defaultFallMultiplier: TimeInterval = 125.0

        ///
        let levelAccum  = TimeInterval(score.level) * defaultFallMultiplier
        let fallingTime = (defaultFallSpeed - levelAccum) / 1000.0

        ///
        return fallingTime
    }

    ///
    private var previousTime: TimeInterval = .infinity
    
    ///
    private var stateMachine: GKStateMachine

    ///
    var render: ((_ board: TileBoard) -> Void)? = nil

    /**
     */
    required init(_ dimensions: (rows: Int, columns: Int), gameScene: GameScene) {
        self.boardDimensions = dimensions
        self.previewDimensions = (rows: 4, columns: 4)
        self.stateMachine = GKStateMachine(states: [
            Game.Initialize(gameScene: gameScene)
          , Game.DropPiece(gameScene: gameScene)
          , Game.InsertPiece(gameScene: gameScene)
          , Game.ApplyCollisions(gameScene: gameScene)
          , Game.GameOver(gameScene: gameScene)
        ])
    }

    /**
     */
    private func reset() {
        self.gameBoard = [[Int]].init(repeating: [Int].init(repeating: 0, count: boardDimensions.columns), count: boardDimensions.rows)
        self.previewBoard = [[Int]].init(repeating: [Int].init(repeating: 0, count: previewDimensions.columns), count: previewDimensions.rows)
        self.previousTime = .infinity
        self.score = GameScore()
    }

    /**
     */
    func start() {
        if stateMachine.currentState == nil {
            stateMachine.enter(Initialize.self)
        } else if stateMachine.currentState is GameOver {
            stateMachine.enter(Initialize.self)
        }
    }

    /**
     */
    func checkCollisions() {
        stateMachine.enter(ApplyCollisions.self)
    }

    /**
     */
    func update(_ currentTime: TimeInterval) {
        if self.previousTime.isInfinite {
            self.previousTime = currentTime
        }
        self.stateMachine.update(deltaTime: currentTime - previousTime)
        self.previousTime = currentTime
    }
}
