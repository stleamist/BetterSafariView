#if os(iOS)

import UIKit

extension UIView {
    
    /// The receiver’s view controller, or `nil` if it has none.
    ///
    /// This property is `nil` if the view has not yet been added to a view controller.
    var viewController: UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.viewController
        } else {
            return nil
        }
    }
}

#endif
