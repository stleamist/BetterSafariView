import Foundation

extension Bool: Identifiable {
    public var id: Bool { self }
}

extension URL: Identifiable {
    public var id: String { self.absoluteString }
}

#if os(iOS)
import SwiftUI

extension UIWindow {
    var topViewController: UIViewController? {
        if var topController = self.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        }

        return nil
    }
}

#endif
