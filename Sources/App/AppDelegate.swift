#if canImport(AppKit)
import AppKit

/**
 The application's designated delegate.
     
 - note: This is entirely optional, since we're creating the `NSApp` instance
         ourselves in `main.swift`.
 */
public final class AppDelegate: NSObject, NSApplicationDelegate
{
    /**
     Informs the application it should close after the last window is closed.

     - parameter sender: The application.
     - returns: Always `true`.
     */
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate
{
    /**
     Assigns `app.delegate` to `self`.
     
     - parameter app: The application which is to use the receiver as its delegate.
     */
    convenience init(with app: NSApplication) {
        self.init()
        app.delegate = self
    }
}
#endif
