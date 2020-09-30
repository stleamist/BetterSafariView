#if os(iOS)

import SwiftUI

struct SafariViewPresentationModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)? = nil
    var representationBuilder: () -> SafariView
    
    private var item: Binding<Bool?> {
        .init(
            get: { self.isPresented ? true : nil },
            set: { self.isPresented = ($0 != nil) }
        )
    }
    
    // Converts `() -> Void` closure to `(Bool) -> Void`
    private func itemRepresentationBuilder(bool: Bool) -> SafariView {
        return representationBuilder()
    }
    
    func body(content: Content) -> some View {
        content.background(
            SafariViewPresenter(
                item: item,
                onDismiss: onDismiss,
                representationBuilder: itemRepresentationBuilder
            )
        )
    }
}

struct ItemSafariViewPresentationModifier<Item: Identifiable>: ViewModifier {
    
    @Binding var item: Item?
    var onDismiss: (() -> Void)? = nil
    var representationBuilder: (Item) -> SafariView
    
    func body(content: Content) -> some View {
        content.background(
            SafariViewPresenter(
                item: $item,
                onDismiss: onDismiss,
                representationBuilder: representationBuilder
            )
        )
    }
}

public extension View {
    
    /// Presents a Safari view when a given condition is true.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to whether the Safari view is presented.
    ///   - onDismiss: A closure executed when the Safari view dismisses.
    ///   - content: A closure returning the `SafariView` to present.
    ///
    func safariView(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        content representationBuilder: @escaping () -> SafariView
    ) -> some View {
        self.modifier(
            SafariViewPresentationModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                representationBuilder: representationBuilder
            )
        )
    }
    
    /// Presents a Safari view using the given item as a data source
    /// for the `SafariView` to present.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional source of truth for the Safari view.
    ///     When representing a non-`nil` item, the system uses `content` to
    ///     create a `SafariView` of the item.
    ///     If the identity changes, the system dismisses a
    ///     currently-presented Safari view and replace it by a new Safari view.
    ///   - onDismiss: A closure executed when the Safari view dismisses.
    ///   - content: A closure returning the `SafariView` to present.
    ///
    func safariView<Item: Identifiable>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        content representationBuilder: @escaping (Item) -> SafariView
    ) -> some View {
        self.modifier(
            ItemSafariViewPresentationModifier(
                item: item,
                onDismiss: onDismiss,
                representationBuilder: representationBuilder
            )
        )
    }
}

#endif
