import SwiftUI

extension View {

    @ViewBuilder
    func modify<Modified: View>(@ModifiedViewBuilder modificationBlock: (Self) -> Modified) -> some View {

        let modified = modificationBlock(self)

        if modified is EmptyView {
            self
        } else {
            modified
        }
    }
}

@_functionBuilder
struct ModifiedViewBuilder {

    static func buildBlock() -> EmptyView {
        EmptyView()
    }

    static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }
}
