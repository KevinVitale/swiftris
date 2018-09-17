/// Numeric grids hold data values.
///
/// - Note:
///     This is not a replacement for the typical matrix construct.
public struct NumericGrid<T: Numeric>: Collection {
    // Private
    //--------------------------------------------------------------------------
    fileprivate var _array: [T]
    private let dimensions: (rows :Int, cols :Int)
    
    // Computed
    //--------------------------------------------------------------------------
    public var rows: Int { return dimensions.rows }
    public var cols: Int { return dimensions.cols }
    
    // Initialization
    //--------------------------------------------------------------------------
    /// Initializes a numeric grid with the given dimensions.
    ///
    /// - Parameters:
    ///     - rows: The height of the grid.
    ///     - cols: The width of the grid.
    public init(rows: Int, columns cols: Int) {
        self.dimensions = (rows, cols)
        self._array = Array(repeating: 0, count: rows * cols)
    }
    
    // Collection
    //--------------------------------------------------------------------------
    public var startIndex: Int { return _array.startIndex  }
    public var endIndex:   Int { return _array.endIndex    }
    
    public func index(after i: Int) -> Int {
        return _array.index(after: i)
    }
    
    // Subscripts
    //--------------------------------------------------------------------------
    public subscript(index: Int) -> T {
        return _array[index]
    }
    
    public subscript(row: Int, col: Int) -> T {
        get { return _array[(row * self.rows) + col] }
        set { _array[(row * self.rows) + col] = newValue }
    }
}
