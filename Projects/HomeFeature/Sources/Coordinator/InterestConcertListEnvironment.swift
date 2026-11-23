import SwiftUI

import Domain

private enum InterestConcertRepositoryKey: EnvironmentKey {
    static var defaultValue: (any InterestConcertRepository)? { nil }
}

public extension EnvironmentValues {
    var interestConcertRepository: (any InterestConcertRepository)? {
        get { self[InterestConcertRepositoryKey.self] }
        set { self[InterestConcertRepositoryKey.self] = newValue }
    }
}
