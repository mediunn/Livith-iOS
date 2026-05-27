//
//  NetworkingFactoryTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("NetworkingFactory")
struct NetworkingFactoryTests {
    @Test("factory 초기화 시 config에 /api/v6 prefix가 자동으로 추가되어야 한다")
    func factory_초기화_시_config에_api_version_prefix가_자동_추가되어야_한다() async throws {
        // Given
        let rawURL = URL(string: "https://test.example.com")!
        let config = NetworkConfig(baseURL: rawURL)

        // When
        let sut = NetworkingFactoryImpl(config: config)

        // Then
        #expect(sut.config.baseURL == URL(string: "https://test.example.com/api/v6")!)
    }

    @Test("factory 초기화 시 onAuthenticationExpired 클로저를 그대로 보관해야 한다")
    func factory_초기화_시_onAuthenticationExpired_클로저를_그대로_보관해야_한다() async throws {
        // Given
        let config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        nonisolated(unsafe) var callbackExecuted = false

        // When
        let sut = NetworkingFactoryImpl(
            config: config,
            onAuthenticationExpired: { callbackExecuted = true }
        )

        // Then
        sut.onAuthenticationExpired()
        #expect(callbackExecuted == true)
    }

    @Test("factory 초기화 시 순환 의존성 없이 내부 의존성이 정상 초기화되어야 한다")
    func factory_초기화_시_순환_의존성_없이_내부_의존성이_정상_초기화되어야_한다() async throws {
        // Given
        let config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)

        // When: 초기화가 성공하면 순환 의존성이 없다는 증거
        let sut = NetworkingFactoryImpl(config: config)

        // Then
        #expect(sut.config.baseURL == URL(string: "https://api.example.com/api/v6")!)
    }

    @Test("makeSongService는 SongService 타입의 인스턴스를 반환해야 한다")
    func makeSongService는_SongService_타입을_반환해야한다() async throws {
        // Given
        let config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)

        // When
        let sut = NetworkingFactoryImpl(config: config)
        let service = sut.makeSongService()

        // Then
        #expect(service is SongService)
    }

    @Test("makeSetlistService는 SetlistService 타입의 인스턴스를 반환해야 한다")
    func makeSetlistService는_SetlistService_타입을_반환해야한다() async throws {
        // Given
        let config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)

        // When
        let sut = NetworkingFactoryImpl(config: config)
        let service = sut.makeSetlistService()

        // Then
        #expect(service is SetlistService)
    }

    @Test("makeCommentService는 CommentService 타입의 인스턴스를 반환해야 한다")
    func makeCommentService는_CommentService_타입을_반환해야한다() async throws {
        // Given
        let config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)

        // When
        let sut = NetworkingFactoryImpl(config: config)
        let service = sut.makeCommentService()

        // Then
        #expect(service is CommentService)
    }
}
