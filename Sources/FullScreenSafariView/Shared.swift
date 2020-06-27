import Foundation

extension Bool: Identifiable {
    public var id: Bool { self }
}

extension URL: Identifiable {
    public var id: String { self.absoluteString }
}

struct ItemStorage<Item: Identifiable> {
    
    private var item: Item?
    
    mutating func updateItem(_ newItem: Item?) -> (oldItem: Item?, newItem: Item?) {
        let oldItem = self.item
        self.item = newItem
        return (oldItem: oldItem, newItem: newItem)
    }
}
