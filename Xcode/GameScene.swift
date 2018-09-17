import SpriteKit

/**
 */
final class GameScene: SKScene {
    private var          scoreLabel: SKLabelNode = SKLabelNode()
    private var     scoreLabelValue: SKLabelNode = SKLabelNode()
    private var      lineCountLabel: SKLabelNode = SKLabelNode()
    private var lineCountLabelValue: SKLabelNode = SKLabelNode()
    private var          levelLabel: SKLabelNode = SKLabelNode()
    private var     levelLabelValue: SKLabelNode = SKLabelNode()

    ///
    var game: Game? = nil

    ///
    var gameBoardNode: SKTileMapNode? = nil {
        willSet {
            gameBoardNode?.removeFromParent()
        }
        didSet {
            if let gameBoardNode = gameBoardNode {
                addChild(gameBoardNode)
            }
        }
    }

    ///
    var currentPieceNode: SKTileMapNode? = nil {
        willSet {
            currentPieceNode?.removeFromParent()
        }
        didSet {
            if let currentPieceNode = currentPieceNode {
                addChild(currentPieceNode)
            }
        }
    }
    
    ///
    var previewPieceNode: SKTileMapNode? = nil {
        willSet {
            previewPieceNode?.removeFromParent()
        }
        didSet {
            if let previewPieceNode = previewPieceNode {
                previewPieceNode.position = CGPoint(x: 352.0, y: 480.0)
                addChild(previewPieceNode)
            }
        }
    }

    ///
    var gameOverScene: SKScene {
        get {
            guard let gameOverScene = childNode(withName: "GameOverScene") as? SKScene else {
                ///
                let newScene = SKScene(size: size)
                newScene.name = "GameOverScene"
                newScene.isHidden = true
                
                ///
                newScene.filter = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputRadiusKey:20.0])
                newScene.backgroundColor = .clear
                newScene.shouldEnableEffects = true
                
                ///
                addChild(newScene)

                ///
                return newScene
            }

            ///
            return gameOverScene
        }
    }

    var gameOverLabel: SKLabelNode {
        get {
            guard let label = childNode(withName: "GameOverLabel") as? SKLabelNode else {
                ///
                let label = SKLabelNode(text: "GAME OVER")
                label.name = "GameOverLabel"
                label.isHidden = true
                
                ///
                label.fontSize = 64.0
                label.position = CGPoint(
                    x: frame.midX
                    , y: frame.midY + 64.0
                )
                
                ///
                addChild(label)

                ///
                return label
            }

            ///
            return label
        }
    }
    
    /**
     */
    private func configureLabels() {
        ///
        scoreLabel.text = "Score:"
        scoreLabel.fontSize = 16.0
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.color = .white
        scoreLabel.position = CGPoint(x: 352.0, y: 224.0) // Row 7

        ///
        scoreLabelValue.text = "0"
        scoreLabelValue.color = .white
        scoreLabelValue.horizontalAlignmentMode = .left
        scoreLabelValue.position = CGPoint(x: 352.0, y: 192.0) // Row 6

        ///
        lineCountLabel.text = "Lines:"
        lineCountLabel.fontSize = 16.0
        lineCountLabel.horizontalAlignmentMode = .left
        lineCountLabel.color = .white
        lineCountLabel.position = CGPoint(x: 352.0, y: 160.0) // Row 5

        ///
        lineCountLabelValue.text = "0"
        lineCountLabelValue.color = .white
        lineCountLabelValue.horizontalAlignmentMode = .left
        lineCountLabelValue.position = CGPoint(x: 352.0, y: 128.0) // Row 4

        ///
        levelLabel.text = "Level:"
        levelLabel.fontSize = 16.0
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.color = .white
        levelLabel.position = CGPoint(x: 352.0, y: 96.0) // Row 3

        ///
        levelLabelValue.text = "0"
        levelLabelValue.color = .white
        levelLabelValue.horizontalAlignmentMode = .left
        levelLabelValue.position = CGPoint(x: 352.0, y: 64.0) // Row 2

        ///
        addChild(scoreLabel)
        addChild(scoreLabelValue)
        addChild(lineCountLabel)
        addChild(lineCountLabelValue)
        addChild(levelLabel)
        addChild(levelLabelValue)
    }

    /**
     */
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        /// - note: Configure the text labels.
        self.configureLabels()

        /// - note: Extract the block texture from our `TileMap`
        guard let texture = gameBoardNode?.tileSet.tileGroups
            .filter({ $0 != .empty() })
            .compactMap({ $0.rules.first?.tileDefinitions.first?.textures.first })
            .first else {
                fatalError("Missing block texture")
        }

        /// - note: Setup the render callbacks
        self.game?.render = { [weak self] in
            switch($0) {
            case .board(let game):
                self?.gameBoardNode?.render(tiles: game, texture: texture, skipEmpty: false)
            case .piece(let piece):
                self?.currentPieceNode?.render(tiles: piece.tiles, texture: texture)
                self?.currentPieceNode?.position = piece.position
            case .preview(let next):
                self?.previewPieceNode?.render(tiles: next, texture: texture)
            case .score(let score):
                self?.levelLabelValue.text     = score.levelDescription
                self?.lineCountLabelValue.text = score.linesDescription
                self?.scoreLabelValue.text     = score.scoreDescription
            }
        }

        /// - note: Start the game!
        self.game?.start()
    }

    /**
     */
    override func update(_ currentTime: TimeInterval) {
        ///
        super.update(currentTime)

        ///
        self.game?.update(currentTime)
    }

    /**
     */
    override func keyDown(with event: NSEvent) {
        switch (event.charactersIgnoringModifiers, event.modifierFlags.contains(.command)) {
        case ("q", true):
            NSApp.terminate(self)
        default: ()
        }
        
        /// Escape
        guard event.keyCode != 53 else {
            game?.start()
            return
        }
        
        /// Space
        guard event.keyCode != 49 else {
            repeat { }
                while(game?.player.move(.down, scene: self) ?? false)
            
            game?.checkCollisions()
            return
        }
        
        interpretKeyEvents([event])
    }
    
    override func moveUp(_ sender: Any?) {
        game?.player.move(.rotate, scene: self)
    }
    
    override func moveDown(_ sender: Any?) {
        if !(game?.player.move(.down, scene: self) ?? false) {
            game?.checkCollisions()
        }
    }
    
    override func moveLeft(_ sender: Any?) {
        game?.player.move(.left, scene: self)
    }
    
    override func moveRight(_ sender: Any?) {
        game?.player.move(.right, scene: self)
    }
}

