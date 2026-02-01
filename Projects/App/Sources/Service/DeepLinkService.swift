//
//  DeepLinkService.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 2/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import KakaoSDKAuth

final class DeepLinkService {
    static let shared = DeepLinkService()

    private init() {}

    func handle(url: URL) {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            _ = AuthController.handleOpenUrl(url: url)
            return
        }

        if url.scheme == "livith" {
            handleDeepLink(url)
        }
    }

    func handle(userInfo: [AnyHashable: Any]) {
        // TODO: 푸시 알림 payload에서 딥링크 추출 후 처리
    }
}

// MARK: - Deep Link Handling

private extension DeepLinkService {
    func handleDeepLink(_ url: URL) {
        guard let host = url.host else { return }

        switch host {
        case "concert":
            handleConcertDeepLink(url)
        case "home":
            break
        default:
            break
        }
    }

    func handleConcertDeepLink(_ url: URL) {
        guard let concertIDString = url.pathComponents.dropFirst().first,
              let concertID = Int(concertIDString)
        else {
            return
        }

        NotificationCenter.default.post(
            name: .openConcertDetail,
            object: nil,
            userInfo: ["concertID": concertID]
        )
    }
}

// MARK: - Notification.Name

public extension Notification.Name {
    static let openConcertDetail = Notification.Name("openConcertDetail")
}
