//
//  DeepLinkService.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 2/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Amplitude
import ConcertFeature
import Domain
import KakaoSDKAuth
import LivithDesignSystem

final class DeepLinkService {
    static let shared = DeepLinkService()

    @MainActor private var pendingInstagramURL: URL?

    private init() {}

    @MainActor
    func consumePendingInstagramURL() -> URL? {
        defer { pendingInstagramURL = nil }

        return pendingInstagramURL
    }

    @MainActor
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
        print("🔔 FCM userInfo: \(userInfo)")

        let typeString = userInfo["notificationType"] as? String
        let notificationType = typeString.flatMap { NotificationType(rawValue: $0) }

        if let notificationType {
            trackPushNotificationTap(type: notificationType)

            if notificationType == .interestConcert {
                NotificationCenter.default.post(name: .openInterestConcert, object: nil)
                return
            }
        }

        let concertID: Int? = {
            if let id = userInfo["concertId"] as? Int {
                return id
            } else if let idString = userInfo["concertId"] as? String {
                return Int(idString)
            } else if let id = userInfo["targetId"] as? Int {
                return id
            } else if let idString = userInfo["targetId"] as? String {
                return Int(idString)
            }
            return nil
        }()

        guard let concertID else {
            print("🔔 FCM: concertID 파싱 실패")
            return
        }

        print("🔔 FCM: concertID=\(concertID), type=\(notificationType?.rawValue ?? "nil")")

        let (initialTab, initialSection): (SegmentedTabBarType.DetailTab, ConcertInfoSection?) = {
            if let notificationType {
                return mapNotificationTypeToTabAndSection(notificationType)
            }
            return (.artistDetail, nil)
        }()

        var userInfoDict: [String: Any] = ["concertID": concertID, "initialTab": initialTab]
        if let section = initialSection {
            userInfoDict["initialSection"] = section
        }

        NotificationCenter.default.post(
            name: .openConcertDetail,
            object: nil,
            userInfo: userInfoDict
        )
    }
}

// MARK: - Deep Link Handling

private extension DeepLinkService {
    @MainActor
    func handleDeepLink(_ url: URL) {
        guard let host = url.host else { return }

        switch host {
        case "concert":
            handleConcertDeepLink(url)
        case "instagram":
            handleInstagramDeepLink(url)
        case "home":
            break
        default:
            break
        }
    }

    @MainActor
    func handleInstagramDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let sourceURLString = components.queryItems?.first(where: { $0.name == "url" })?.value,
              let sourceURL = URL(string: sourceURLString)
        else {
            return
        }

        // 콜드 런치 시 메인 탭이 아직 구독 전이라 알림이 유실되므로, 탭 진입 시 소비하도록 보관한다
        pendingInstagramURL = sourceURL

        NotificationCenter.default.post(
            name: .openInstagramMatch,
            object: nil,
            userInfo: ["sourceURL": sourceURL]
        )
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
            userInfo: ["concertID": concertID, "initialTab": SegmentedTabBarType.DetailTab.artistDetail]
        )
    }

    func mapNotificationTypeToTabAndSection(_ type: NotificationType) -> (SegmentedTabBarType.DetailTab, ConcertInfoSection?) {
        switch type {
        case .concertInfoUpdateSetlist:
            return (.setlist, nil)
        case .concertInfoUpdateMD:
            return (.concertInfo, .merchandise)
        case .concertInfoUpdateSchedule, .concertInfoUpdateTicket:
            return (.concertInfo, .schedule)
        default:
            return (.artistDetail, nil)
        }
    }

    func trackPushNotificationTap(type: NotificationType) {
        switch type {
        case .interestConcert:
            AmplitudeService.shared.trackEvent(tag: .click(.pushInterestConcert))
        case .preTicketingOpen, .preTicketing1D, .preTicketing30M:
            AmplitudeService.shared.trackEvent(tag: .click(.pushPreBookingSchedule))
        case .generalTicketingOpen, .generalTicketing1D, .generalTicketing30M:
            AmplitudeService.shared.trackEvent(tag: .click(.pushBookingSchedule))
        case .concertInfoUpdateSetlist:
            AmplitudeService.shared.trackEvent(tag: .click(.pushConcertUpdateSetlist))
        case .concertInfoUpdateMD:
            AmplitudeService.shared.trackEvent(tag: .click(.pushConcertUpdateMd))
        case .concertInfoUpdateDetail:
            AmplitudeService.shared.trackEvent(tag: .click(.pushConcertUpdateDetail))
        case .concertInfoUpdateSchedule:
            AmplitudeService.shared.trackEvent(tag: .click(.pushConcertUpdateSchedule))
        case .concertInfoUpdateTicket:
            AmplitudeService.shared.trackEvent(tag: .click(.pushConcertUpdateTicket))
        case .artistConcertOpen:
            AmplitudeService.shared.trackEvent(tag: .click(.pushFavoriteArtistConcertOpen))
        case .recommend:
            AmplitudeService.shared.trackEvent(tag: .click(.pushRecommendedConcert))
        }
    }
}

// MARK: - Notification.Name

public extension Notification.Name {
    static let openConcertDetail = Notification.Name("openConcertDetail")
    static let openInterestConcert = Notification.Name("openInterestConcert")
    static let openInstagramMatch = Notification.Name("openInstagramMatch")
}
