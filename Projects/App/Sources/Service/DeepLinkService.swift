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

    private init() {}

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
        guard let typeString = userInfo["type"] as? String,
              let concertIDString = userInfo["concertId"] as? String,
              let concertID = Int(concertIDString),
              let notificationType = NotificationType(rawValue: typeString)
        else {
            return
        }

        trackPushNotificationTap(type: notificationType)
        let (initialTab, initialSection) = mapNotificationTypeToTabAndSection(notificationType)

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
        case .ticket1D, .ticket7D, .ticketToday:
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
}
