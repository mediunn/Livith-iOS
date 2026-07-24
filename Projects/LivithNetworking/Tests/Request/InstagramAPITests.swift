//
//  InstagramAPITests.swift
//  LivithNetworkingTests
//
//  Created by youz2me on 7/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("InstagramAPI")
struct InstagramAPITests {
    @Test("추출 잡 생성은 extraction-jobs 경로에 POST로 요청해야 한다")
    func 추출_잡_생성은_extraction_jobs_경로에_POST로_요청해야_한다() {
        let sut = InstagramAPI.createExtractionJob(instagramURL: "https://www.instagram.com/p/abc123/")

        #expect(sut.path == "/extraction-jobs")
        #expect(sut.method == .post)
        #expect(sut.authentication == .required)
    }

    @Test("추출 잡 생성은 인스타그램 URL을 body로 전달해야 한다")
    func 추출_잡_생성은_인스타그램_URL을_body로_전달해야_한다() throws {
        let sut = InstagramAPI.createExtractionJob(instagramURL: "https://www.instagram.com/p/abc123/")

        guard case .body(let body) = sut.task else {
            Issue.record("task가 body가 아닙니다")
            return
        }
        let request = try #require(body as? DTO.Request.CreateExtractionJob)
        #expect(request.instagramUrl == "https://www.instagram.com/p/abc123/")
    }
}
