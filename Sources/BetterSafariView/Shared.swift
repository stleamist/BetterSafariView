import Foundation

extension Bool: Identifiable {
    public var id: Bool { self }
}

extension URL: Identifiable {
    public var id: String { self.absoluteString }
}
