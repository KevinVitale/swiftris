import SpriteKit

class ScoreboardNode: SKNode {
    enum GameData {
        case level(Int)
        case lines(Int)
        case score(Int)
        
        var rawValue: Int {
            switch self {
            case .level(let rawValue): return rawValue
            case .lines(let rawValue): return rawValue
            case .score(let rawValue): return rawValue
            }
        }
    }
    
    convenience init(forScene scene: SKScene) {
        self.init()
        self.configureLabels(forScene: scene)
        self.name = "//scoreboard"
    }
    
    private var          scoreLabel: SKLabelNode = SKLabelNode()
    private var     scoreLabelValue: SKLabelNode = SKLabelNode()
    private var      lineCountLabel: SKLabelNode = SKLabelNode()
    private var lineCountLabelValue: SKLabelNode = SKLabelNode()
    private var          levelLabel: SKLabelNode = SKLabelNode()
    private var     levelLabelValue: SKLabelNode = SKLabelNode()
    
    func setScore(_ score: GameData) {
        switch score {
        case .level:
            levelLabelValue.text = "\(score.rawValue)"
        case .lines:
            lineCountLabelValue.text = "\(score.rawValue)"
        case .score:
            scoreLabelValue.text = "\(score.rawValue)"
        }
    }
    
    private func configureLabels(forScene scene: SKScene) {
        ///
        scoreLabel.text = "Score:"
        scoreLabel.fontSize = 16.0
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.color = .white
        scoreLabel.position = convert(CGPoint(x: 352.0, y: 224.0), to: scene)  // Row 7
        
        ///
        scoreLabelValue.text = "0"
        scoreLabelValue.color = .white
        scoreLabelValue.horizontalAlignmentMode = .left
        scoreLabelValue.position = convert(CGPoint(x: 352.0, y: 192.0), to: scene) // Row 6
        
        ///
        lineCountLabel.text = "Lines:"
        lineCountLabel.fontSize = 16.0
        lineCountLabel.horizontalAlignmentMode = .left
        lineCountLabel.color = .white
        lineCountLabel.position = convert(CGPoint(x: 352.0, y: 160.0), to: scene) // Row 5
        
        ///
        lineCountLabelValue.text = "0"
        lineCountLabelValue.color = .white
        lineCountLabelValue.horizontalAlignmentMode = .left
        lineCountLabelValue.position = convert(CGPoint(x: 352.0, y: 128.0), to: scene) // Row 4
        
        ///
        levelLabel.text = "Level:"
        levelLabel.fontSize = 16.0
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.color = .white
        levelLabel.position = convert(CGPoint(x: 352.0, y: 96.0), to: scene) // Row 3
        
        ///
        levelLabelValue.text = "0"
        levelLabelValue.color = .white
        levelLabelValue.horizontalAlignmentMode = .left
        levelLabelValue.position = convert(CGPoint(x: 352.0, y: 64.0), to: scene) // Row 2
        
        ///
        addChild(scoreLabel)
        addChild(scoreLabelValue)
        addChild(lineCountLabel)
        addChild(lineCountLabelValue)
        addChild(levelLabel)
        addChild(levelLabelValue)
    }
}
