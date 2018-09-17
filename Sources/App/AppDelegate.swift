#if canImport(AppKit)
import AppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Informs the application it should close after the last window is closed.
    ///
    /// - Parameters:
    ///     - sender: The application.
    ///
    /// - Returns: Always `true`.
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate {
    /// Assigns `app.delegate` to `self`.
    ///
    /// - Parameters:
    ///     - app: The application which is to use the receiver as its delegate.
    convenience init(with app: NSApplication) {
        self.init()
        app.delegate = self
    }
}
#endif
