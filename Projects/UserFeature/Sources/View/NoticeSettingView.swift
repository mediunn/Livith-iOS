//
//  NoticeSettingView.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import LivithFoundation

// MARK: - NoticeSettingView

public struct NoticeSettingView: View {

    // MARK: - Property

    @State private var isDeviceNotificationEnabled: Bool = false
    @State private var benefitNotification: Bool = true
    @State private var nightNotification: Bool = true
    @State private var ticketSchedule: Bool = true
    @State private var concertInfoUpdate: Bool = true
    @State private var favoriteArtistConcert: Bool = true
    @State private var preferenceBasedConcert: Bool = true
    @State private var showMarketingConsentSheet: Bool = false
    @State private var noticeModalType: LivithModalType? = nil

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
                    if !isDeviceNotificationEnabled {
                        deviceNotificationSection
                            .padding(.top, 20)
                            .padding(.horizontal, 16)
                        
                        Divider()
                            .frame(height: 4)
                            .background(Color.livithColor(.black80))
                    }

                    benefitSection
                        .padding(.top, isDeviceNotificationEnabled ? 20 : 30)
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
            checkNotificationPermission()
        }
        .onChange(of: benefitNotification) { oldValue, newValue in
            if !oldValue && newValue {
                showMarketingConsentSheet = true
            } else if oldValue && !newValue {
                noticeModalType = .normal(
                    title: "알림 거부 안내",
                    message: noticeModalMessage(action: "거부")
                )
            }
        }
        .onChange(of: nightNotification) { _, newValue in
            let action = newValue ? "동의" : "거부"
            noticeModalType = .normal(
                title: "야간 푸시 알림 \(action) 안내",
                message: noticeModalMessage(action: action)
            )
        }
        .livithSheet(isPresented: $showMarketingConsentSheet, detents: [.height(260)]) {
            MarketingConsentBottomSheet(
                onConfirm: {
                    showMarketingConsentSheet = false
                    noticeModalType = .normal(
                        title: "알림 동의 안내",
                        message: noticeModalMessage(action: "동의")
                    )
                },
                onCancel: {
                    benefitNotification = false
                    showMarketingConsentSheet = false
                }
            )
        }
        .crossDissolve(isPresented: Binding(
            get: { noticeModalType != nil },
            set: { if !$0 { noticeModalType = nil } }
        )) {
            if let modalType = noticeModalType {
                LivithModal(
                    type: modalType,
                    onConfirm: { noticeModalType = nil }
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
                isOn: $benefitNotification
            )

            notificationRow(
                title: Literals.nightNotification,
                isOn: $nightNotification
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
                isOn: $ticketSchedule
            )

            notificationRow(
                title: Literals.concertInfoUpdate,
                isOn: $concertInfoUpdate
            )

            notificationRow(
                title: Literals.favoriteArtistConcert,
                isOn: $favoriteArtistConcert
            )

            notificationRow(
                title: Literals.preferenceBasedConcert,
                isOn: $preferenceBasedConcert
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

// MARK: - Helper

private extension NoticeSettingView {
    func checkNotificationPermission() {
        Task { @MainActor in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            isDeviceNotificationEnabled = settings.authorizationStatus == .authorized
        }
    }

    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }

    func noticeModalMessage(action: String) -> String {
        let dateString = DateFormatterService.string(from: Date(), type: .dotDateTime)
        return "전송자 : 라이빗\n수신 일시 : \(dateString)\n처리 내용 : 알림 \(action) 처리 완료"
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
