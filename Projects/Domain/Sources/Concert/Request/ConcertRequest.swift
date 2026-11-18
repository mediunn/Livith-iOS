import Foundation

public struct ConcertRequest {
    public static let maxTitleLength = 50

    public let title: String
    public let url: String?
    public let shouldAutoRegister: Bool
    public let requestContent: String?

    public static func isTitleValid(_ title: String) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedTitle.isEmpty && trimmedTitle.count <= maxTitleLength
    }

    public init(
        title: String,
        url: String?,
        shouldAutoRegister: Bool,
        requestContent: String?
    ) throws(ConcertError) {
        guard Self.isTitleValid(title) else { throw .invalidRequest }
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.url = Self.nonemptyInput(url)
        self.shouldAutoRegister = shouldAutoRegister
        self.requestContent = Self.nonemptyInput(requestContent)
    }

    private static func nonemptyInput(_ input: String?) -> String? {
        guard let value = input?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else { return nil }
        return value
    }
}
