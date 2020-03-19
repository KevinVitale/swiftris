struct Grid<Element: Numeric>: Collection {
    init(rows: Int = 0, columns: Int = 0, defaultValue: Element = .zero) {
        self.columns = columns
        self.rows    = rows
        self._values = Array(repeating: defaultValue, count: columns * rows)
    }

    private var _values :Array<Element>

    let rows    :Int
    let columns :Int
    
    var startIndex :Int { _values.startIndex }
    var endIndex   :Int { _values.endIndex   }
    
    func index(after i: Int) -> Int {
        _values.index(after: i)
    }
    
    subscript(position: Int) -> Element {
        get { _values[abs(position)] }
        set { _values[abs(position)] = newValue }
    }
    
    subscript(column: Int, row: Int) -> Element {
        get { self[self.columns * row + column] }
        set { self[self.columns * row + column] = newValue }
    }
}

extension Grid: CustomDebugStringConvertible {
    var debugDescription: String {
        var debugDescription = "rows: \(rows); columns: \(columns)\n---\n"
        for row in (0..<firstEmptyRow).reversed() {
            for column in (0..<firstEmptyColumn) {
                debugDescription.append("\(self[column, row].magnitude)\t")
            }
            debugDescription.append("\n")
        }
        return debugDescription
    }
}

extension Grid {
    enum Rotation {
        case clockwise
        case counterClockwise
    }
    
    private var firstNonEmptyRow: Int {
       (self.firstIndex(where: { $0 != .zero }) ?? .zero) / rows
    }
    
    private var firstNonEmptyColumn: Int {
        self.transposed().firstNonEmptyRow
    }
    
    var firstEmptyRow: Int {
        rows - ((self.reversed().firstIndex(where: { $0 != .zero }) ?? .zero) / rows)
    }
    
    var firstEmptyColumn: Int {
        self.transposed().firstEmptyRow
    }

    /**
     * Shifts all the values to be anchored at [0, 0].
     */
    private func compacted() -> Self {
        var shifted = Self(rows: self.rows, columns: self.columns, defaultValue: .zero)
        let slice   = self.suffix((rows - firstNonEmptyRow) * rows)
        
        let offset = firstNonEmptyColumn

        for var index in slice.startIndex..<slice.endIndex {
            if slice.formIndex(&index, offsetBy: offset, limitedBy: slice.endIndex - 1) {
                let idx = index - offset - slice.startIndex
                shifted[idx] = slice[index]
            }
        }
        
        return shifted
    }

    // https://en.wikipedia.org/wiki/In-place_matrix_transposition#Properties_of_the_permutation
    func transposed() -> Self {
        let N = self.rows
        let M = self.columns
        
        var grid = Self(rows: M, columns: N)
        
        for n in 0..<N {
            for m in 0..<M {
                let a = M * n + m
                let p = (a == (M * N) - 1) ? a : (N * a) % (M * N - 1)
                grid[p] = self[a]
            }
        }
        return grid
    }
    
    // https://stackoverflow.com/a/8664879
    mutating func rotate(_ rotation: Rotation) {
        var transposed = self.transposed().compacted()

        switch rotation {
        case .clockwise:
            for row in 0..<rows {
                let startIndex = row * rows
                let endIndex   = startIndex + columns
                let reversed   = transposed._values[startIndex..<endIndex].reversed()
                transposed._values.replaceSubrange(startIndex..<endIndex, with: reversed)
            }
        case .counterClockwise:
            var reversedColumns = transposed
            for column in 0..<columns {
                for (row, value) in (startIndex..<endIndex)
                    .filter({ $0 % columns == 0 })
                    .reversed()
                    .enumerated() {
                        reversedColumns[(row * columns) + column] = transposed[value + column]
                }
            }
            transposed = reversedColumns
        }
        
        self = transposed.compacted()
    }
}

extension Grid where Element == TileColor {
    @discardableResult
    mutating func removeCompletedRows() -> IndexSet {
        var completedRows = IndexSet()
        for row in 0..<firstEmptyRow {
            let startIndex = (row - completedRows.count) * columns
            let endIndex   = startIndex.advanced(by: columns)
            let slice      = self[startIndex..<endIndex]
            
            if slice.firstIndex(of: .empty) == nil {
                completedRows.insert(row)
                self._values.removeSubrange(startIndex..<endIndex)
                self._values.append(contentsOf: Array<Element>(repeating: .empty, count: rows * columns))
            }
        }
        return completedRows
    }
}

import SpriteKit
extension Grid {
    func redraw(_ tileMap: SKTileMapNode?, configureSprite: @escaping (SKSpriteNode, Element) -> ()) {
        guard let tileMap = tileMap, tileMap.numberOfRows == rows, tileMap.numberOfColumns == columns else {
            return
        }
        
        for row in 0..<self.rows {
            for column in 0..<self.columns {
                let value = self[self.columns * row + column]
                let sprite = self.sprite(inTileMap: tileMap, atColumn: column, row: row)
                configureSprite(sprite, value)
            }
        }
    }
    
    private func sprite(inTileMap tileMap: SKTileMapNode, atColumn column: Int, row: Int) -> SKSpriteNode {
        let tileTexture = tileMap.tileDefinition(atColumn: column, row: row)?.textures.first
        let tileCenter  = tileMap.centerOfTile(atColumn: column, row: row)
        var tileSprite  = tileMap.nodes(at: tileCenter).first as? SKSpriteNode
        
        if tileSprite == nil {
            tileSprite = SKSpriteNode(texture: tileTexture, size: tileMap.tileSize)
            tileSprite?.position = tileCenter
            tileMap.addChild(tileSprite!)
        }

        return tileSprite!
    }
    
}
