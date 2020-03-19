import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    override init() {
        super.init()
        UserDefaults.standard.register(defaults: ["ghostEnabled":true])
        UserDefaults.standard.register(defaults: ["soundEnabled":false])
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let sceneView = window.contentView as! SKView
        let gameScene = GameScene(size: sceneView.frame.size)
        sceneView.presentScene(gameScene)
        
        sceneView.toggle(debug: [.nodeCount, .fps])
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

extension NSEvent {
    var isQuitEvent: Bool {
        switch (self.charactersIgnoringModifiers, self.modifierFlags.contains(.command)) {
        case ("q", true):
            return true
        default:
            return false
        }
    }
}
