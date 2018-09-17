/**
 */
struct GameScore {
    /**
     */
    enum LineMultiplier: Int {
        case one   = 1
        case two   = 2
        case three = 3
        case four  = 4

        /**
         */
        fileprivate func score(level: Int) -> Int {
            switch(self) {
            case   .one: return   40 * (level + 1)
            case   .two: return  100 * (level + 1)
            case .three: return  300 * (level + 1)
            case  .four: return 1200 * (level + 1)
            }
        }
    }
    
    ///
    static private let linesPerLevel = 10

    ///
    fileprivate var lines: Int = 0
    fileprivate var score: Int = 0

    ///
    var level: Int {
        return (lines / GameScore.linesPerLevel)
    }

    ///
    var levelDescription: String { return "\(level)" }
    var scoreDescription: String { return "\(score)" }
    var linesDescription: String { return "\(lines)" }
}

infix operator +: AdditionPrecedence

/**
 */
extension GameScore {
    /**
     */
    static func +(score: GameScore, lines: LineMultiplier) -> GameScore {
        return GameScore(lines: score.lines + lines.rawValue, score: score.score + lines.score(level: score.level))
    }
}
