struct Identified<Wrapped: Hashable>: Identifiable {

    var id: Wrapped

    init(_ id: Wrapped) {
        self.id = id
    }
}
