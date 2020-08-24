import SwiftUI

struct WebAuthenticationPresentationModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    var representationBuilder: () -> WebAuthenticationSession
    
    private var item: Binding<Bool?> {
        .init(
            get: { self.isPresented ? true : nil },
            set: { self.isPresented = ($0 != nil) }
        )
    }
    
    // Converts `() -> Void` closure to `(Bool) -> Void`
    private func itemRepresentationBuilder(bool: Bool) -> WebAuthenticationSession {
        return representationBuilder()
    }
    
    func body(content: Content) -> some View {
        content.background(
            WebAuthenticationPresenter(
                item: item,
                representationBuilder: itemRepresentationBuilder
            )
        )
    }
}

struct ItemWebAuthenticationPresentationModifier<Item: Identifiable>: ViewModifier {
    
    @Binding var item: Item?
    var representationBuilder: (Item) -> WebAuthenticationSession
    
    func body(content: Content) -> some View {
        content.background(
            WebAuthenticationPresenter(
                item: $item,
                representationBuilder: representationBuilder
            )
        )
    }
}

public extension View {
    
    /// Starts a web authentication session when a given condition is true.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to whether the web authentication session should be started.
    ///   - content: A closure returning the `WebAuthenticationSession` to start.
    ///
    func webAuthenticationSession(
        isPresented: Binding<Bool>,
        content representationBuilder: @escaping () -> WebAuthenticationSession
    ) -> some View {
        self.modifier(
            WebAuthenticationPresentationModifier(
                isPresented: isPresented,
                representationBuilder: representationBuilder
            )
        )
    }
    
    // FIXME: Dismiss and replace the view if the identity changes
    
    /// Starts a web authentication session using the given item as a data source
    /// for the `WebAuthenticationSession` to start.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional source of truth for the web authentication session.
    ///     When representing a non-`nil` item, the system uses `content` to
    ///     create a session representation of the item.
    ///     If the identity changes, the system cancels a
    ///     currently-started session and replace it by a new session.
    ///   - content: A closure returning the `WebAuthenticationSession` to start.
    ///
    /// - Experiment:
    ///     The functionality that replaces a session on the `item`'s identity change is **not implemented**,
    ///     as there is no non-hacky way to be notified when the session's dismissal animation is completed.
    ///
    func webAuthenticationSession<Item: Identifiable>(
        item: Binding<Item?>,
        content representationBuilder: @escaping (Item) -> WebAuthenticationSession
    ) -> some View {
        self.modifier(
            ItemWebAuthenticationPresentationModifier(
                item: item,
                representationBuilder: representationBuilder
            )
        )
    }
}
