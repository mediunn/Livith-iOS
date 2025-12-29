//
//  TestTokenHelper.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

/// 테스트 환경에서 인증 토큰을 설정하기 위한 헬퍼
/// Development.xcconfig에서 토큰을 읽어와 Keychain에 저장합니다.
///
/// xcconfig 설정:
/// - LIVITH_ACCESS_TOKEN = 액세스 토큰
/// - LIVITH_REFRESH_TOKEN = 리프레시 토큰
public enum TestTokenHelper {
    private static let storage = TokenStorage(serviceID: "com.youz2me.livith.network")
    private static let networkBundle = Bundle(identifier: "com.youz2me.livith.livithnetwork") ?? Bundle.main

    /// xcconfig에서 토큰을 읽어 Keychain에 저장
    public static func setupToken() {
        let accessToken = networkBundle.object(forInfoDictionaryKey: "LIVITH_ACCESS_TOKEN") as? String ?? ""
        let refreshToken = networkBundle.object(forInfoDictionaryKey: "LIVITH_REFRESH_TOKEN") as? String ?? ""

        guard !accessToken.isEmpty, !refreshToken.isEmpty else {
            print("⚠️ [TestTokenHelper] Development.xcconfig에 토큰이 설정되지 않았습니다.")
            print("  - LIVITH_ACCESS_TOKEN")
            print("  - LIVITH_REFRESH_TOKEN")
            return
        }

        let token = Token(
            accessToken: accessToken,
            refreshToken: refreshToken,
            refreshTokenIssuedAt: Date()
        )

        do {
            try storage.save(token)
            print("✅ [TestTokenHelper] 토큰 설정 완료")
        } catch {
            print("❌ [TestTokenHelper] 토큰 저장 실패: \(error)")
        }
    }

    /// Keychain에서 토큰 제거
    public static func removeToken() {
        try? storage.remove()
    }
}
