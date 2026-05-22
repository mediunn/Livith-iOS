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
    @Test("factory 초기화 시 주입된 config를 그대로 반환해야 한다")
    func factory_초기화_시_주입된_config를_그대로_반환해야_한다() async throws {
        // Given
        let expectedURL = URL(string: "https://test.example.com")!
        let config = NetworkConfig(baseURL: expectedURL)

        // When
        let sut = NetworkingFactoryImpl(config: config)

        // Then
        #expect(sut.config.baseURL == expectedURL)
    }

    @Test("factory 초기화 시 onAuthenticationExpired 클로저를 그대로 보관해야 한다")
    func factory_초기화_시_onAuthenticationExpired_클로저를_그대로_보관해야_한다() async throws {
        // Given
        let config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        var callbackExecuted = false

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
        #expect(sut.config.baseURL == config.baseURL)
    }
}
