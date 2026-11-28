import Observation

import Domain

@Observable
public final class HomeDependencies {
    let concertCatalogRepository: any ConcertCatalogRepository
    let interestConcertRepository: any InterestConcertRepository
    let concertRequestRepository: any ConcertRequestRepository

    public init(
        concertCatalogRepository: any ConcertCatalogRepository,
        interestConcertRepository: any InterestConcertRepository,
        concertRequestRepository: any ConcertRequestRepository
    ) {
        self.concertCatalogRepository = concertCatalogRepository
        self.interestConcertRepository = interestConcertRepository
        self.concertRequestRepository = concertRequestRepository
    }
}
