
import Foundation
import Domain
import DIContainer
import LivithNetwork

public struct ConcertRepositoryImpl: ConcertRepository {
    private let diContainer: DIContainer
    
    public func fetchAllConcertList(startDate: Date?, concertID: Int?) async throws(ConcertError) -> [Concert] {
        fatalError("Not implemented yet")
    }

    public func fetchConcertArtistInfo(concertID: Int) async throws(ConcertError) -> Artist {
        fatalError("Not implemented yet")
    }

    public func fetchConcertSetlistList(concertID: Int) async throws(ConcertError) -> [Setlist] {
        fatalError("Not implemented yet")
    }

    public func fetchConcertMerchandiseList(concertID: Int) async throws(ConcertError) -> [ConcertMerchandise] {
        fatalError("Not implemented yet")
    }

    public func fetchConcertInfoList(concertID: Int) async throws(ConcertError) -> [ConcertInfo] {
        fatalError("Not implemented yet")
    }

    public func fetchConcertCultureList(concertID: Int) async throws(ConcertError) -> [ConcertCulture] {
        fatalError("Not implemented yet")
    }

    public func fetchConcertScheduleList(concertID: Int) async throws(ConcertError) -> [ConcertSchedule] {
        fatalError("Not implemented yet")
    }

    public func fetchConcert(concertID: Int) async throws(ConcertError) -> Concert {
        fatalError("Not implemented yet")
    }

    public func fetchSearchConcertSectionList() async throws(ConcertError) -> [ConcertSection] {
        fatalError("Not implemented yet")
    }

    public func fetchHomeConcertSectionList() async throws(ConcertError) -> [ConcertSection] {
        fatalError("Not implemented yet")
    }

    public func fetchMainSetlist(concertID: Int) async throws(ConcertError) -> Setlist? {
        fatalError("Not implemented yet")
    }
}
