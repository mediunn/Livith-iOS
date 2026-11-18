public struct ConcertCommentContent {
    public static let maxLength = 400

    public let value: String

    public init(_ value: String) throws(CommentError) {
        guard !value.isEmpty else { throw .emptyContent }
        guard value.count <= Self.maxLength else { throw .contentTooLong }
        self.value = value
    }
}
