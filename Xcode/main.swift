import Foundation
import AppKit
import SpriteKit

// Create 'window'
//------------------------------------------------------------------------------
let gameWindow = Window(styleMask: [.titled, .miniaturizable]) { SKViewController() }
let gameScene  = GameScene(size: CGSize(width: 480, height: 640))

gameWindow.viewController?.skView.presentScene(gameScene)
gameWindow.viewController?.skView.frame = CGRect(
    origin: .zero
    , size: gameScene.size
)
gameWindow.setContentSize(gameScene.size)
gameWindow.center()

// Create 'delegate'
//------------------------------------------------------------------------------
let appDelegate = AppDelegate(with: .shared)

// run
//------------------------------------------------------------------------------
NSApp.run()
