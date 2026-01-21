
import Foundation
import Domain
import DIContainer
import LivithNetwork

struct SongRepositoryImpl: SongRepository {
    private let songService: SongService
    private let mapper: SongMapper = .init()
    private let errorMapper: SongErrorMapper = .init()
    
    func fetchSongLyrics(songID: Int) async throws(SongError) -> SongLyrics {
        do {
            let response: DTO.Response.FetchSongLyrics = try await songService.request(
                .fetchSongLyrics(songID: songID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSongError(error)
        }
    }

    func fetchSongFanchant(setlistID: Int, songID: Int) async throws(SongError) -> SongFanchant {
        do {
            let response: DTO.Response.FetchSongFanchant = try await songService.request(
                .fetchSongFanchant(setlistID: setlistID, songID: songID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSongError(error)
        }
    }
}
