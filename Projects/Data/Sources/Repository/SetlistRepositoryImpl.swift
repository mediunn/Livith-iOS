
import Foundation
import Domain
import DIContainer
import LivithNetwork

public struct SetlistRepositoryImpl: SetlistRepository {    
    public func fetchSetlist(concertID: Int, setlistID: Int) async throws(SetlistError) -> Setlist {
        fatalError("Not implemented yet")
    }

    public func fetchSetlistSongs(setlistID: Int) async throws(SetlistError) -> [SetlistSong] {
        fatalError("Not implemented yet")
    }
}
