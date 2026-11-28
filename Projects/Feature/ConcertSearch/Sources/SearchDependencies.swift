import Observation

import Domain

@Observable
public final class SearchDependencies {
    public let repository: any SearchRepository

    public init(repository: any SearchRepository) {
        self.repository = repository
    }
}
