//
//  NoticeSettingStore.swift
//  UserFeature
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import UserNotifications

import DIContainer
import Domain

// MARK: - State

struct NoticeSettingState {
    var isDeviceNotificationEnabled: Bool = false
    var marketingConsent: Bool = false
    var benefitNotification: Bool = false
    var nightNotification: Bool = false
    var ticketSchedule: Bool = true
    var concertInfoUpdate: Bool = true
    var favoriteArtistConcert: Bool = true
    var preferenceBasedConcert: Bool = true
    var showMarketingConsentSheet: Bool = false
    var modalInfo: ModalInfo? = nil

    struct ModalInfo: Equatable {
        let title: String
        let message: String
    }
}

// MARK: - Intent

enum NoticeSettingIntent {
    case viewDidAppear
    case checkDeviceNotification
    case toggleBenefitNotification(Bool)
    case toggleNightNotification(Bool)
    case toggleTicketSchedule(Bool)
    case toggleConcertInfoUpdate(Bool)
    case toggleFavoriteArtistConcert(Bool)
    case togglePreferenceBasedConcert(Bool)
    case confirmMarketingConsent
    case cancelMarketingConsent
    case dismissModal
    case _setDeviceNotificationEnabled(Bool)
    case _setAuthority(UserAuthority)
    case _setConsentResult(NotificationConsentResult, field: NotificationConsentField, isAgreed: Bool)
    case _revertToggle(NotificationConsentField)
}

// MARK: - Store

final class NoticeSettingStore: ObservableObject {
    @Published private(set) var state = NoticeSettingState()

    @Injected private var userRepository: UserRepository
    @Injected private var notificationRepository: NotificationRepository

    @MainActor
    func send(_ intent: NoticeSettingIntent) {
        switch intent {
        case .viewDidAppear:
            checkDeviceNotificationPermission()
            performFetchUserAuthority()

        case .checkDeviceNotification:
            checkDeviceNotificationPermission()

        case .toggleBenefitNotification(let newValue):
            state.benefitNotification = newValue
            if newValue {
                if state.marketingConsent {
                    performUpdateConsent(field: .benefitAlert, isAgreed: true)
                } else {
                    state.showMarketingConsentSheet = true
                }
            } else {
                performUpdateConsent(field: .benefitAlert, isAgreed: false)
            }

        case .toggleNightNotification(let newValue):
            state.nightNotification = newValue
            performUpdateConsent(field: .nightAlert, isAgreed: newValue)

        case .toggleTicketSchedule(let newValue):
            state.ticketSchedule = newValue
            performUpdateConsent(field: .ticketAlert, isAgreed: newValue)

        case .toggleConcertInfoUpdate(let newValue):
            state.concertInfoUpdate = newValue
            performUpdateConsent(field: .infoAlert, isAgreed: newValue)

        case .toggleFavoriteArtistConcert(let newValue):
            state.favoriteArtistConcert = newValue
            performUpdateConsent(field: .interestAlert, isAgreed: newValue)

        case .togglePreferenceBasedConcert(let newValue):
            state.preferenceBasedConcert = newValue
            performUpdateConsent(field: .recommendAlert, isAgreed: newValue)

        case .confirmMarketingConsent:
            state.showMarketingConsentSheet = false
            performMarketingConsentThenBenefitAlert()

        case .cancelMarketingConsent:
            state.benefitNotification = false
            state.showMarketingConsentSheet = false

        case .dismissModal:
            state.modalInfo = nil

        case ._setDeviceNotificationEnabled(let isEnabled):
            state.isDeviceNotificationEnabled = isEnabled

        case ._setAuthority(let authority):
            state.marketingConsent = authority.marketingConsent
            state.benefitNotification = authority.benefitNotification
            state.nightNotification = authority.nightNotification
            state.ticketSchedule = authority.ticketSchedule
            state.concertInfoUpdate = authority.concertInfoUpdate
            state.favoriteArtistConcert = authority.favoriteArtistConcert
            state.preferenceBasedConcert = authority.preferenceBasedConcert

        case ._setConsentResult(let result, let field, let isAgreed):
            let action = isAgreed ? "동의" : "거부"
            let title: String
            switch field {
            case .benefitAlert:
                title = "알림 \(action) 안내"
            case .nightAlert:
                title = "야간 푸시 알림 \(action) 안내"
            default:
                return
            }
            let message = "전송자 : \(result.sender)\n수신 일시 : \(result.agreedAt)\n처리 내용 : \(result.message)"
            state.modalInfo = .init(title: title, message: message)

        case ._revertToggle(let field):
            switch field {
            case .benefitAlert:
                state.benefitNotification.toggle()
            case .nightAlert:
                state.nightNotification.toggle()
            case .ticketAlert:
                state.ticketSchedule.toggle()
            case .infoAlert:
                state.concertInfoUpdate.toggle()
            case .interestAlert:
                state.favoriteArtistConcert.toggle()
            case .recommendAlert:
                state.preferenceBasedConcert.toggle()
            }
        }
    }
}

// MARK: - Helper

private extension NoticeSettingStore {
    func checkDeviceNotificationPermission() {
        Task { @MainActor in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            send(._setDeviceNotificationEnabled(settings.authorizationStatus == .authorized))
        }
    }

    func performFetchUserAuthority() {
        Task {
            guard let user = try? await userRepository.fetchUser() else { return }
            
            await MainActor.run {
                send(._setAuthority(user.authority))
            }
        }
    }

    func performMarketingConsentThenBenefitAlert() {
        Task {
            do {
                _ = try await notificationRepository.updateMarketingConsent()
                let result = try await notificationRepository.updateNotificationConsent(
                    field: .benefitAlert,
                    isAgreed: true
                )
                await MainActor.run {
                    state.marketingConsent = true
                    send(._setConsentResult(result, field: .benefitAlert, isAgreed: true))
                }
            } catch {
                await MainActor.run {
                    send(._revertToggle(.benefitAlert))
                }
            }
        }
    }

    func performUpdateConsent(field: NotificationConsentField, isAgreed: Bool) {
        Task {
            do {
                let result = try await notificationRepository.updateNotificationConsent(
                    field: field,
                    isAgreed: isAgreed
                )
                await MainActor.run {
                    send(._setConsentResult(result, field: field, isAgreed: isAgreed))
                }
            } catch {
                await MainActor.run {
                    send(._revertToggle(field))
                }
            }
        }
    }
}
