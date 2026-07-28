//
//  HomeAPITests.swift
//  LivithNetworkingTests
//
//  Created by youz2me on 7/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("HomeAPI")
struct HomeAPITests {
    @Test("관심 콘서트 단건 추가는 concertID 경로에 POST로 요청해야 한다")
    func 관심_콘서트_단건_추가는_concertID_경로에_POST로_요청해야_한다() {
        let sut = HomeAPI.updateInterestedConcert(concertID: 1)

        #expect(sut.path == "/users/interest-concert/1")
        #expect(sut.method == .post)
        #expect(sut.authentication == .required)
    }

    @Test("관심 콘서트 단건 추가는 request body를 보내지 않아야 한다")
    func 관심_콘서트_단건_추가는_request_body를_보내지_않아야_한다() {
        let sut = HomeAPI.updateInterestedConcert(concertID: 1)

        guard case .plain = sut.task else {
            Issue.record("task가 plain이 아닙니다")
            return
        }
    }
}
