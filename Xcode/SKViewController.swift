import AppKit
import SpriteKit

class SKViewController: NSViewController {
    /// The SpriteKit view managed by the controller.
    var skView: SKView {
        return self.view as! SKView
    }
    
    /// The scene associated with the `SKView`.
    var skScene: SKScene? {
        return self.skView.scene
    }
    
    ///
    override func loadView() {
        self.view = SKView()
        self.view.frame = .zero
        self.view.autoresizingMask = [.width, .height]
    }
    
    ///
    override func viewDidLayout() {
        super.viewDidLayout()
        self.skScene?.size = self.view.frame.size
    }
}
