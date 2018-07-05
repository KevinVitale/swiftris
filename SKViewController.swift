import AppKit
import SpriteKit

/**
 */
class SKViewController<Scene: SKScene>: NSViewController {
    /// The scene.
    /// - note: Assume a one-to-one pairing of view controller and scene type.
    let scene = Scene()
    
    /**
     */
    override func loadView() {
        self.view = SKView()
        self.view.autoresizingMask = [.width, .height]
    }

    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        #if debug
            self.skView.toggle(debug: [.fps, .drawCount, .nodeCount])
        #endif
    }

    /**
     */
    override func viewDidLayout() {
        super.viewDidLayout()
        self.scene.size = self.view.frame.size
        if self.skView.scene == nil {
            self.skView.presentScene(self.scene)
        }
    }
}

/**
 */
extension SKViewController {
    /// A coerced version of the receiver's view as type `SKView`.
    var skView: SKView {
        return self.view as! SKView
    }
}
