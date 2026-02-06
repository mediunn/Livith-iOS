//
//  NoticeSettingView.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

// MARK: - NoticeSettingView

public struct NoticeSettingView: View {

    // MARK: - Property

    @StateObject private var store = NoticeSettingStore()
    @Environment(\.scenePhase) private var scenePhase

    private let onBack: () -> Void

    // MARK: - Initializer

    public init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                VStack(spacing: 0) {
                    if !store.state.isDeviceNotificationEnabled {
                        deviceNotificationSection
                            .padding(.top, 20)
                            .padding(.horizontal, 16)

                        Divider()
                            .frame(height: 4)
                            .background(Color.livithColor(.black80))
                    }

                    benefitSection
                        .padding(.top, store.state.isDeviceNotificationEnabled ? 20 : 30)
                        .padding(.horizontal, 16)

                    concertSection
                        .padding(.top, 32)
                        .padding(.horizontal, 16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
        .onAppear {
            store.send(.viewDidAppear)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                store.send(.checkDeviceNotification)
            }
        }
        .livithSheet(isPresented: marketingConsentSheetBinding, detents: [.height(260)]) {
            MarketingConsentBottomSheet(
                onConfirm: {
                    store.send(.confirmMarketingConsent)
                },
                onCancel: {
                    store.send(.cancelMarketingConsent)
                }
            )
        }
        .crossDissolve(isPresented: modalBinding) {
            if let modalInfo = store.state.modalInfo {
                LivithModal(
                    type: .normal(title: modalInfo.title, message: modalInfo.message),
                    onConfirm: { store.send(.dismissModal) }
                )
            }
        }
    }
}

// MARK: - UIComponents

private extension NoticeSettingView {
    var navigationBar: some View {
        LivithNavigationView(type: .back(title: Literals.title, onBack: onBack))
    }

    var deviceNotificationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(Literals.deviceNotificationHeader)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            VStack(spacing: 10) {
                Image.livithImage(.notice)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(Literals.settingPath)
                    .notosans(.caption1Regular)
                    .foregroundStyle(Color.livithColor(.black50))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            LivithButton(Literals.openDeviceSetting, variant: .primary) {
                openAppSettings()
            }
        }
        .padding(.bottom, 30)
    }

    var benefitSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(Literals.benefitSectionTitle)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))

                Text(Literals.benefitSectionSubtitle)
                    .notosans(.body4Regular)
                    .foregroundStyle(Color.livithColor(.black50))
            }

            notificationRow(
                title: Literals.benefitNotification,
                isOn: benefitNotificationBinding
            )

            notificationRow(
                title: Literals.nightNotification,
                isOn: nightNotificationBinding
            )
        }
    }

    var concertSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(Literals.concertSectionTitle)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))

                Text(Literals.concertSectionSubtitle)
                    .notosans(.body4Regular)
                    .foregroundStyle(Color.livithColor(.black50))
            }

            notificationRow(
                title: Literals.ticketSchedule,
                isOn: ticketScheduleBinding
            )

            notificationRow(
                title: Literals.concertInfoUpdate,
                isOn: concertInfoUpdateBinding
            )

            notificationRow(
                title: Literals.favoriteArtistConcert,
                isOn: favoriteArtistConcertBinding
            )

            notificationRow(
                title: Literals.preferenceBasedConcert,
                isOn: preferenceBasedConcertBinding
            )
        }
    }

    func notificationRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.black30))

            Spacer()

            Toggle("", isOn: isOn)
                .toggleStyle(NoticeToggleStyle())
        }
    }
}

// MARK: - Bindings

private extension NoticeSettingView {
    var benefitNotificationBinding: Binding<Bool> {
        Binding(
            get: { store.state.benefitNotification },
            set: { store.send(.toggleBenefitNotification($0)) }
        )
    }

    var nightNotificationBinding: Binding<Bool> {
        Binding(
            get: { store.state.nightNotification },
            set: { store.send(.toggleNightNotification($0)) }
        )
    }

    var ticketScheduleBinding: Binding<Bool> {
        Binding(
            get: { store.state.ticketSchedule },
            set: { store.send(.toggleTicketSchedule($0)) }
        )
    }

    var concertInfoUpdateBinding: Binding<Bool> {
        Binding(
            get: { store.state.concertInfoUpdate },
            set: { store.send(.toggleConcertInfoUpdate($0)) }
        )
    }

    var favoriteArtistConcertBinding: Binding<Bool> {
        Binding(
            get: { store.state.favoriteArtistConcert },
            set: { store.send(.toggleFavoriteArtistConcert($0)) }
        )
    }

    var preferenceBasedConcertBinding: Binding<Bool> {
        Binding(
            get: { store.state.preferenceBasedConcert },
            set: { store.send(.togglePreferenceBasedConcert($0)) }
        )
    }

    var marketingConsentSheetBinding: Binding<Bool> {
        Binding(
            get: { store.state.showMarketingConsentSheet },
            set: { if !$0 { store.send(.cancelMarketingConsent) } }
        )
    }

    var modalBinding: Binding<Bool> {
        Binding(
            get: { store.state.modalInfo != nil },
            set: { if !$0 { store.send(.dismissModal) } }
        )
    }
}

// MARK: - Helper

private extension NoticeSettingView {
    func openAppSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - NoticeToggleStyle

private struct NoticeToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color.livithColor(.yellow30) : Color.livithColor(.black90))
                .frame(width: 58, height: 32)
                .overlay(
                    Circle()
                        .fill(configuration.isOn ? Color.white : Color.livithColor(.black50))
                        .frame(width: 24, height: 24)
                        .shadow(color: .black.opacity(0.15), radius: 8)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}

// MARK: - Constants

private extension NoticeSettingView {
    enum Literals {
        static let title = "알림 설정"
        static let deviceNotificationHeader = "알림을 받기 위해\n기기 알림을 켜주세요"
        static let allowNotification = "알림 허용"
        static let settingPath = "설정 > 알림 > 라이빗"
        static let openDeviceSetting = "기기 알림 켜기"

        static let benefitSectionTitle = "혜택 및 이벤트 알림"
        static let benefitSectionSubtitle = "혜택 등 이벤트 알림을 보내드려요"
        static let benefitNotification = "유저를 위한 혜택 알림"
        static let nightNotification = "야간 알림 (21시 ~ 08시)"

        static let concertSectionTitle = "관심 콘서트 알림"
        static let concertSectionSubtitle = "알림 신청한 소식을 가장 먼저 알려드려요"
        static let ticketSchedule = "예매 일정"
        static let concertInfoUpdate = "콘서트 정보 업데이트"
        static let favoriteArtistConcert = "선호 아티스트의 콘서트 오픈"
        static let preferenceBasedConcert = "취향 기반 콘서트 알림"
    }
}

// MARK: - Preview

#Preview("Device Notification Off") {
    NoticeSettingView(onBack: {})
}
