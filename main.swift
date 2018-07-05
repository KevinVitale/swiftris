import AppKit
import SpriteKit
import GameKit

extension NSWindow
{
    /**
     Creates a new window with the given `viewController`.
     
     - note:
     This a convenience initializer which calls:
        - `makeKeyAndOrderFront(nil)`; and
        - `center()`
     
     - parameter viewController: The value assigned to `contentViewController`.
     */
    convenience init<ViewController: NSViewController>(_ viewController: () -> ViewController) {
        self.init(contentViewController: viewController())
        self.makeKeyAndOrderFront(nil)
        self.center()
    }
}

// Create 'window'
//------------------------------------------------------------------------------
let window = NSWindow {
    let viewController = SKViewController<GameScene>()
    viewController.view.frame = NSRect(x: 0, y: 0, width: 480, height: 640)
    
    let gameBoardDimensions = (rows: 20, columns: 10)
    viewController.scene.game = Game(gameBoardDimensions, gameScene: viewController.scene)
    viewController.scene.gameBoardNode = SKTileMapNode(gameBoardDimensions)
    
    let previewBoardDimensions = (rows: 4, columns: 4)
    viewController.scene.previewPieceNode = SKTileMapNode(previewBoardDimensions)
    viewController.scene.currentPieceNode = SKTileMapNode(previewBoardDimensions)

    return viewController
}
window.styleMask.remove(.resizable)

// Create 'delegate'
//------------------------------------------------------------------------------
let appDelegate = AppDelegate(with: .shared)

// activate `NSApp`
//------------------------------------------------------------------------------
NSApp.setActivationPolicy(.regular)
NSApp.activate(ignoringOtherApps: true)

// run
//------------------------------------------------------------------------------
NSApp.run()
