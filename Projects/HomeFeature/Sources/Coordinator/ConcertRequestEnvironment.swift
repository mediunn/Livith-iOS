import SwiftUI

import Domain

private enum ConcertRequestRepositoryKey: EnvironmentKey {
    static var defaultValue: (any ConcertRequestRepository)? { nil }
}

public extension EnvironmentValues {
    var concertRequestRepository: (any ConcertRequestRepository)? {
        get { self[ConcertRequestRepositoryKey.self] }
        set { self[ConcertRequestRepositoryKey.self] = newValue }
    }
}
