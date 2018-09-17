import AppKit
import SpriteKit
import GameKit

// Create 'window'
//------------------------------------------------------------------------------
let window = Window {
    let controller = SKViewController()
    let scene = GameScene(size: CGSize(width: 480, height: 640))
    controller.skView.presentScene(scene)
    controller.skView.frame = NSRect(origin: .zero, size: scene.size)

    return controller
}
window.styleMask.remove(.resizable)

// Create 'delegate'
//------------------------------------------------------------------------------
let appDelegate = AppDelegate(with: .shared)

// run
//------------------------------------------------------------------------------
NSApp.run()
