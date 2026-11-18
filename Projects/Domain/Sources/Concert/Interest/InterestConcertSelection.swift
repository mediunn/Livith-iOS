public struct InterestConcertSelection {
    public private(set) var concertIDs: [Int]
    private var savedConcertIDs: [Int]

    public var hasUnsavedChanges: Bool {
        Set(concertIDs) != Set(savedConcertIDs)
    }

    public init(concertIDs: [Int] = []) {
        self.concertIDs = concertIDs
        self.savedConcertIDs = concertIDs
    }

    public mutating func toggle(concertID: Int) {
        if concertIDs.contains(concertID) {
            remove(concertID: concertID)
        } else {
            concertIDs.append(concertID)
        }
    }

    public mutating func remove(concertID: Int) {
        concertIDs.removeAll { $0 == concertID }
    }

    public mutating func markSaved(concertIDs: [Int]) {
        savedConcertIDs = concertIDs
    }
}
