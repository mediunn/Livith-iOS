public protocol ConcertDetailRepository {
    func fetchConcertArtistInfo(concertID: Int) async throws(ConcertError) -> Artist
    func fetchConcertSetlistList(concertID: Int) async throws(ConcertError) -> [Setlist]
    func fetchConcertMerchandiseList(concertID: Int) async throws(ConcertError) -> [ConcertMerchandise]
    func fetchConcertInfoList(concertID: Int) async throws(ConcertError) -> [ConcertInfo]
    func fetchConcertCultureList(concertID: Int) async throws(ConcertError) -> [ConcertCulture]
    func fetchConcertScheduleList(concertID: Int) async throws(ConcertError) -> [ConcertSchedule]
    func fetchConcert(concertID: Int) async throws(ConcertError) -> Concert
    func fetchMainSetlist(concertID: Int) async throws(ConcertError) -> Setlist?
}
