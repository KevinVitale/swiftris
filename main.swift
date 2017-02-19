import AppKit
import SpriteKit
import GameKit

///-----------------------------------------------------------------------------
///-----------------------------------------------------------------------------
/// ⚠️ *WARNING* ⚠️
///-----------------------------------------------------------------------------
///-----------------------------------------------------------------------------
/// Confused why this file exists?
/// Refer to `NSApplicationMain` in this document:
/// https://developer.apple.com/library/prerelease/content/documentation/Swift/Conceptual/Swift_Programming_Language/Attributes.html
///-----------------------------------------------------------------------------
///-----------------------------------------------------------------------------

/**
 Bootstraps the `NSApp` and starts its run loop, optionally setting a delegate.

 - parameter delegate: An optional application delegate.
 - returns: Never.
 */
private func bootstrapApp(window: NSWindow, delegate: NSApplicationDelegate? = nil) -> Never {
    // initialize `NSApp`
    NSApplication.shared()

    // assign `delegate`
    NSApp.delegate = delegate

    // activate `NSApp`
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)

    // present `window` 
    window.makeKeyAndOrderFront(nil)

    // enter run-loop
    NSApp.run()
    exit(0)
}

/**
 Creates the application's primary window.
 
 - parameter title: The title of the window.
 - parameter frame: The window's frame.
 
 - returns: A instance of `NSWindow`.
 */
private func createWindow(_ viewController: NSViewController, title: String = "swiftris", frame rect: NSRect = NSRect(x: 0, y: 0, width: 480, height: 640)) -> NSWindow {
    ///
    let styleMask: NSWindowStyleMask = [
        .titled,
        .closable,
        .borderless
    ]

    ///
    let window   = NSWindow(contentRect: rect, styleMask: styleMask, backing: .buffered, defer: false)
    window.title = title

    ///
    window.contentView = viewController.view
    viewController.view.setFrameSize(rect.size)

    ///
    return window
}

///
let gameBoardDimensions = (rows: 20, columns: 10)
let previewBoardDimensions = (rows: 4, columns: 4)

///
private let gameBoardMap = SKTileMapNode(gameBoardDimensions)
private let gamePieceMap = SKTileMapNode(previewBoardDimensions)
private let previewMap = SKTileMapNode(previewBoardDimensions)

///
private let viewController = SKViewController<GameScene>()
private let window = createWindow(viewController)

///
let game = Game(gameBoardDimensions, gameScene: viewController.scene)

///
viewController.scene.game = game
viewController.scene.gameBoardNode = gameBoardMap
viewController.scene.currentPieceNode = gamePieceMap
viewController.scene.previewPieceNode = previewMap

///
game.player.inputHandler.keyDown = { scene, event in
    ///
    guard let scene = scene as? GameScene
        , let game = scene.game else {
            fatalError()
    }

    ///
    let player = game.player

    /// Escape
    guard event.keyCode != 53 else {
        return game.start()
    }
    
    /// Space
    guard event.keyCode != 49 else {
        repeat { }
            while(player.move(.down, scene: scene))
        return game.checkCollisions()
    }

    ///
    guard event.modifierFlags.contains(.numericPad) else {
        return
    }

    ///
    guard let theArrow = event.charactersIgnoringModifiers as NSString? else {
        return
    }

    ///
    switch(Int(theArrow.character(at: 0))) {
    case NSUpArrowFunctionKey:
        player.move(.rotate, scene: scene)
    case NSDownArrowFunctionKey:
        if !player.move(.down, scene: scene) {
            game.checkCollisions()
        }
    case NSLeftArrowFunctionKey:
        player.move(.left, scene: scene)
    case NSRightArrowFunctionKey:
        player.move(.right, scene: scene)
    default: ()
    }
}

///
let appDelegate = AppDelegate()

///
bootstrapApp(window: window, delegate: appDelegate)
