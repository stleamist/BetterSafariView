#if os(iOS) || os(macOS) || os(watchOS)

import SwiftUI
import AuthenticationServices
#if os(iOS)
import SafariServices
#endif

#if os(iOS)
typealias ViewType = UIView
typealias ViewRepresentableType = UIViewRepresentable
#elseif os(macOS)
typealias ViewType = NSView
typealias ViewRepresentableType = NSViewRepresentable
#elseif os(watchOS)
// Use `WKInterfaceInlineMovie` as a concrete interface objct type,
// since there is no public initializer for `WKInterfaceObject`.
typealias ViewType = WKInterfaceInlineMovie
typealias ViewRepresentableType = WKInterfaceObjectRepresentable
#endif

struct WebAuthenticationPresenter<Item: Identifiable>: ViewRepresentableType {
    
    // MARK: Representation
    
    @Binding var item: Item?
    var representationBuilder: (Item) -> WebAuthenticationSession
    
    // MARK: ViewRepresentable
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    #if os(iOS)
    
    func makeUIView(context: Context) -> ViewType {
        return makeView(context: context)
    }
    
    func updateUIView(_ uiView: ViewType, context: Context) {
        
        updateView(uiView, context: context)
        
        // To set a delegate for the presentation controller of an `SFAuthenticationViewController` as soon as possible,
        // check the view controller presented by `view.viewController` then set it as a delegate on every view updates.
        // INFO: `SFAuthenticationViewController` is a private subclass of `SFSafariViewController`.
        guard #available(iOS 14.0, *) else {
            context.coordinator.setInteractiveDismissalDelegateIfPossible()
            return
        }
    }
    
    #elseif os(macOS)
    
    func makeNSView(context: Context) -> ViewType {
        return makeView(context: context)
    }
    
    func updateNSView(_ nsView: ViewType, context: Context) {
        updateView(nsView, context: context)
    }
    
    #elseif os(watchOS)
    
    func makeWKInterfaceObject(context: Context) -> ViewType {
        return makeView(context: context)
    }
    
    func updateWKInterfaceObject(_ wkInterfaceObject: ViewType, context: Context) {
        updateView(wkInterfaceObject, context: context)
    }
    
    #endif
    
    private func makeView(context: Context) -> ViewType {
        return context.coordinator.view
    }
    
    private func updateView(_ view: ViewType, context: Context) {
        // Keep the coordinator updated with a new presenter struct.
        context.coordinator.parent = self
        context.coordinator.item = item
    }
}

extension WebAuthenticationPresenter {
    
    class Coordinator: NSObject {
        
        // MARK: Parent Copying
        
        var parent: WebAuthenticationPresenter
        
        init(parent: WebAuthenticationPresenter) {
            self.parent = parent
        }
        
        // MARK: View Controller Holding
        
        let view = ViewType()
        private weak var session: ASWebAuthenticationSession?
        
        // MARK: Item Handling
        
        var item: Item? {
            didSet(oldItem) {
                handleItemChange(from: oldItem, to: item)
            }
        }
        
        // Ensure the proper presentation handler is executed only once
        // during a one SwiftUI view update life cycle.
        private func handleItemChange(from oldItem: Item?, to newItem: Item?) {
            switch (oldItem, newItem) {
            case (.none, .none):
                ()
            case let (.none, .some(newItem)):
                startWebAuthenticationSession(with: newItem)
            case (.some, .some):
                ()
            case (.some, .none):
                cancelWebAuthenticationSession()
            }
        }
        
        // MARK: Presentation Handlers
        
        private func startWebAuthenticationSession(with item: Item) {
            let representation = parent.representationBuilder(item)
            let session = ASWebAuthenticationSession(
                url: representation.url,
                callbackURLScheme: representation.callbackURLScheme,
                completionHandler: { (callbackURL, error) in
                    self.resetItemBinding()
                    representation.completionHandler(callbackURL, error)
                }
            )
            
            #if os(iOS) || os(macOS)
            session.presentationContextProvider = presentationContextProvider
            #endif
            
            representation.applyModification(to: session)
            
            session.start()
            
            self.session = session
        }
        
        private func cancelWebAuthenticationSession() {
            session?.cancel()
        }
        
        // MARK: Dismissal Handlers
        
        private func resetItemBinding() {
            parent.item = nil
        }
        
        #if os(iOS) || os(macOS)
        
        // MARK: PresentationContextProvider
        
        // INFO: `ASWebAuthenticationPresentationContextProviding` provides an window
        // to present an `SFAuthenticationViewController`, and usually presents the `SFAuthenticationViewController`
        // by calling `present(_:animated:completion:)` method from a root view controller of the window.
        
        private lazy var presentationContextProvider = PresentationContextProvider(coordinator: self)
        
        class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
            
            unowned var coordinator: WebAuthenticationPresenter.Coordinator
            
            init(coordinator: WebAuthenticationPresenter.Coordinator) {
                self.coordinator = coordinator
            }
            
            // MARK: ASWebAuthenticationPresentationContextProviding
            
            func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
                return coordinator.view.window!
            }
        }
        
        #endif
        
        #if os(iOS)
        
        // MARK: InteractiveDismissalDelegate
        
        // There is a problem that `item` is not set to `nil` after the sheet is dismissed with pulling down
        // because the completion handler is not called on this case due to a system bug on iOS 13.
        // To resolve this issue, set `interactiveDismissalDelegate` as a presentation controller delegate of
        // `SFAuthenticationViewController` so that ensures the completion handler is always called.
        
        @available(iOS, introduced: 13.0, deprecated: 14.0)
        private lazy var interactiveDismissalDelegate = InteractiveDismissalDelegate(coordinator: self)
        
        @available(iOS, introduced: 13.0, deprecated: 14.0)
        func setInteractiveDismissalDelegateIfPossible() {
            guard let safariViewController = view.viewController?.presentedViewController as? SFSafariViewController else {
                return
            }
            safariViewController.presentationController?.delegate = interactiveDismissalDelegate
        }
        
        @available(iOS, introduced: 13.0, deprecated: 14.0)
        class InteractiveDismissalDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
            
            weak var coordinator: WebAuthenticationPresenter.Coordinator?
            
            init(coordinator: WebAuthenticationPresenter.Coordinator) {
                self.coordinator = coordinator
            }
            
            // MARK: UIAdaptivePresentationControllerDelegate
            
            func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
                coordinator?.resetItemBinding()
            }
        }
        
        #endif
    }
}

#endif
