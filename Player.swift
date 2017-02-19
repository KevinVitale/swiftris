import SpriteKit

/**
 */
class Player {
    ///
    private(set) var currentPiece: (piece: Piece?, tileColor: SKTileMapNode.TileColor, tiles: [[Int]]) = (nil, .random(), [[Int]]())

    ///
    private(set) var nextPiece: (piece: Piece?, tileColor: SKTileMapNode.TileColor) = (.random(at: .zero), .random())

    ///
    private(set) var inputHandler = InputHandler()

    /**
     */
    func generateNextPiece(in boardDimension: (rows: Int, columns: Int), pieceDimension: (rows: Int, columns: Int), tileSize: CGFloat = 32.0) {
        ///
        let piece = self.nextPiece.piece
        let tileColor = piece?.preferredTileColor ?? self.nextPiece.tileColor

        ///
        let defaultArray = piece!.defaultArray(tileColor: tileColor)
        let missingRows = pieceDimension.rows.distance(to: defaultArray.count)

        ///
        let tileRow = (boardDimension.rows - pieceDimension.rows) - missingRows
        let tileColumn = pieceDimension.columns
        
        ///
        let tilePosition = CGPoint(
            x: CGFloat(tileColumn) * tileSize,
            y: CGFloat(tileRow) * tileSize
        )

        ///
        self.currentPiece = (piece?.position(at: tilePosition), tileColor, piece!.defaultArray(tileColor: tileColor))

        ///
        let nextPiece: Piece = .random()
        self.nextPiece = (nextPiece, nextPiece.preferredTileColor)
    }

    /**
     */
    @discardableResult
    func move(_ move: Move, scene: GameScene?) -> Bool {
        guard let gameBoardNode = scene?.gameBoardNode
            , let gameBoard = scene?.game?.gameBoard
            , var piece = currentPiece.piece else {
                return false
        }

        ///
        let tileSize = gameBoardNode.tileSize

        ///
        var tiles = currentPiece.tiles

        ///
        switch move {
        case .rotate:
            ///
            tiles = tiles.rotated()
            
            ///
            switch(type: piece, rows: tiles.count) {
            case (.long(let position), 1):
                let transform = CGAffineTransform(translationX: tileSize.width.negated(), y: tileSize.height.multiplied(by: 2))
                piece = piece.position(at: position.applying(transform))
            case (.long(let position), _):
                let transform = CGAffineTransform(translationX: tileSize.width, y: tileSize.height.multiplied(by: -2))
                piece = piece.position(at: position.applying(transform))
            default: ()
            }
        default:
            let scale = CGAffineTransform(scaleX: tileSize.width, y: tileSize.height)
            piece = piece.position(at: move.translate(at: piece.position, scale: scale))
        }

        ///
        let tileRow = gameBoardNode.tileRowIndex(fromPosition: piece.position)
        let tileColumn = gameBoardNode.tileColumnIndex(fromPosition: piece.position)

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
                return false
            }

            ///
            let rowTiles = gameBoard[rowIndex].lazy

            ///
            for (column, value) in array.lazy.enumerated() {
                ///
                let columnIndex = column.advanced(by: tileColumn)

                ///
                if columnIndex < 0 || columnIndex >= gameBoardNode.numberOfColumns {
                    return false
                }

                ///
                if rowTiles[columnIndex] != 0 && value != 0 {
                    return false
                }
            }
        }

        self.currentPiece = (piece, currentPiece.tileColor, tiles)
        scene?.game?.render?(.piece(
            position: piece.position
             , tiles: tiles
            ))
        return true
    }
}

/**
 */
extension Collection where Iterator.Element == [Int], IndexDistance == Int {
    ///
    private var columns: Int {
        var total = 0
        forEach { array in
            if (array.endIndex > total) {
                total = array.endIndex
            }
        }
        return total
    }

    /**
     */
    func rotated() -> [[Int]] {
        ///
        var transposed = [[Int]](repeating: [Int](repeating: 0, count: self.count), count: self.columns)

        ///
        for (row, array) in enumerated() {
            for (column, value) in array.reversed().enumerated() {
                transposed[column][row] = value
            }
        }

        ///
        return transposed
    }
}
/**
 */
final class InputHandler {
    typealias InputCallback = (SKScene, NSEvent) -> Void
    typealias KeyboardCallback = InputCallback

    ///
    final var inputUp: InputCallback? = nil

    ///
    final var inputDown: InputCallback? = nil

    ///
    final var inputMoved: InputCallback? = nil

    ///
    final var inputDragged: InputCallback? = nil

    ///
    final var keyUp: KeyboardCallback? = nil

    ///
    final var keyDown: KeyboardCallback? = nil
}

/**
 */
enum Move {
    case up
    case down
    case left
    case right
    case rotate

    /**
     */
    fileprivate func translate(at point: CGPoint, scale: CGAffineTransform = .identity) -> CGPoint {
        var transform: CGAffineTransform = .identity
        switch(self) {
        case .up:    transform = transform.translatedBy(x: 0, y: 1 * scale.d)
        case .down:  transform = transform.translatedBy(x: 0, y: -1 * scale.d)
        case .left:  transform = transform.translatedBy(x: -1 * scale.a, y: 0)
        case .right: transform = transform.translatedBy(x:  1 * scale.a, y: 0)
        case .rotate: return point
        }

        return point.applying(transform)
    }
}
