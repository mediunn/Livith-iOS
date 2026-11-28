import Foundation
import Testing

import Domain
import LivithNetwork
@testable import UserData

struct UserRepositoryImplTests {
    @Test("사용자 정보를 연속 조회하면 두 번째 요청의 실패가 그대로 전달된다")
    func fetchUserPropagatesSecondRequestFailure() async throws {
        let url = try #require(URL(string: "https://example.com"))
        let response = try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
        let body = """
        {
            "statusCode": 200, "message": "ok",
            "data": {
                "id": 1, "provider": "kakao", "nickname": "테스트",
                "marketingConsent": false, "hasPreferredGenre": false
            }
        }
        """
        let transport = MockNetworkTransport(outputList: [
            .success(Data(body.utf8), response),
            .failure(URLError(.notConnectedToInternet))
        ])
        let client = NetworkClient(config: NetworkConfig(baseURL: url), transport: transport)
        let repository = UserRepositoryImpl(networkClient: client)

        let user = try await repository.fetchUser()
        #expect(user.nickname == "테스트")
        await #expect(throws: UserError.noConnection) {
            try await repository.fetchUser()
        }
        #expect(await transport.requests().count == 2)
    }
}
