
import Foundation
import Domain
import DIContainer
import LivithNetwork

public struct CommentRepositoryImpl: CommentRepository {
    private let diContainer: DIContainer
    
    public func fetchConcertComments(
        concertID: Int,
        cursor: (createdAt: String, id: Int)?,
        size: Int?
    ) async throws(CommentError) -> (comments: [ConcertComment], cursor: (createdAt: String, id: Int)?, totalCount: Int) {
        fatalError("Not implemented yet")
    }

    public func createComment(concertID: Int, content: String) async throws(CommentError) -> ConcertComment {
        fatalError("Not implemented yet")
    }

    public func deleteComment(commentID: Int) async throws(CommentError) {
        fatalError("Not implemented yet")
    }

    public func reportComment(commentID: Int, content: String?) async throws(CommentError) {
        fatalError("Not implemented yet")
    }
}
