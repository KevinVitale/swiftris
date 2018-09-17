import AppKit
import SpriteKit
import GameKit

// Create 'window'
//------------------------------------------------------------------------------
let window = Window {
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
