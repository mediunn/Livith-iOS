public struct PreferenceSelection<Item: Identifiable & Equatable>: Equatable {
    public enum ToggleResult {
        case changed
        case limitReached
        case itemUnavailable
    }

    public private(set) var items: [Item]
    private let initialItems: [Item]

    public var hasChangesToSave: Bool {
        !items.isEmpty && items != initialItems
    }

    public init(_ items: [Item]) {
        self.items = items
        self.initialItems = items
    }

    public mutating func toggle(id: Item.ID, availableItem: Item?) -> ToggleResult {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: index)
            return .changed
        }
        guard items.count < PreferenceSelectionRule.maxCount else { return .limitReached }
        guard let availableItem, availableItem.id == id else { return .itemUnavailable }
        items.append(availableItem)
        return .changed
    }
}
