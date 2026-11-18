//
//  MockConcertRequestRepository.swift
//  ShareFeatureTests
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockConcertRequestRepository: ConcertRequestRepository {
    var requestConcertErrorStub: ConcertError?
    var requestConcertDelay: UInt64 = 0

    var requestConcertCallCount: Int = 0
    var requestConcertTitle: String?
    var requestConcertURL: String?
    var requestConcertAutoRegister: Bool?
    var requestConcertContent: String?

    func requestConcert(_ request: ConcertRequest) async throws(ConcertError) {
        requestConcertCallCount += 1
        requestConcertTitle = request.title
        requestConcertURL = request.url
        requestConcertAutoRegister = request.shouldAutoRegister
        requestConcertContent = request.requestContent
        if requestConcertDelay > 0 {
            try? await Task.sleep(nanoseconds: requestConcertDelay)
        }
        if let error = requestConcertErrorStub {
            throw error
        }
    }
}
