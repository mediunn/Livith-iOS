//
//  SettingView.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/28/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

// MARK: - SettingView

struct SettingView: View {

    // MARK: - Property

    @State private var overlayType: OverlayType = .none

    @StateObject private var logoutStore = LogoutStore()

    @Environment(\.userCoordinator) private var coordinator

    // MARK: - Initializer

    init() {}

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            VStack(spacing: 12) {
                LivithListItem(Literals.noticeSetting, type: .navigation, action: { coordinator?.push(to: .noticeSetting) })

                LivithListItem(Literals.updateNote, type: .navigation, action: showUpdateNote)

                LivithListItem(Literals.terms, type: .navigation, action: showTerms)

                LivithListItem(Literals.versionInfo, type: .value(Constant.versionString))

                LivithListItem(Literals.logout, type: .action, action: showLogoutModal)

                LivithListItem(Literals.deleteAccount, type: .action, action: { coordinator?.push(to: .deleteUser) })
            }
            .padding(.top, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
        .sheet(isPresented: isSheetPresented) {
            if let url = overlayType.sheetURL {
                SafariView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .crossDissolve(isPresented: Binding(
            get: { overlayType == .logout },
            set: { if !$0 { overlayType = .none } }
        ), dismissOnTapOutside: true) {
            LivithDangerModal(
                message: Literals.logoutAlertMessage,
                confirmTitle: Literals.logoutAlertConfirm,
                cancelTitle: Literals.logoutAlertCancel,
                type: .confirm(onConfirm: {
                    overlayType = .none
                    performLogout()
                }),
                onCancel: {
                    overlayType = .none
                }
            )
        }
        .onChange(of: logoutStore.state.logoutResult) { _, newResult in
            handleLogoutResult(newResult)
        }
    }
}

// MARK: - UIComponents

private extension SettingView {
    var navigationBar: some View {
        LivithNavigationView(type: .back(title: Literals.title, onBack: { coordinator?.pop() }))
    }
}

// MARK: - Helper

private extension SettingView {
    var isSheetPresented: Binding<Bool> {
        Binding(
            get: { overlayType.sheetURL != nil },
            set: { if !$0 { overlayType = .none } }
        )
    }

    func showUpdateNote() {
        overlayType = .updateNote
    }

    func showTerms() {
        overlayType = .terms
    }

    func showLogoutModal() {
        overlayType = .logout
    }

    func performLogout() {
        logoutStore.send(.logout)
    }

    func handleLogoutResult(_ result: LogoutResult) {
        switch result {
        case .idle:
            break
        case .success:
            NotificationCenter.default.post(name: Notification.Name("reloginRequired"), object: nil)
        case .failure:
            break
        }
    }
}

// MARK: - OverlayType

private extension SettingView {
    enum OverlayType: Equatable {
        case none
        case terms
        case updateNote
        case logout

        var sheetURL: URL? {
            switch self {
            case .terms:
                return Constant.termsURL
            case .updateNote:
                return Constant.updateNoteURL
            default:
                return nil
            }
        }
    }
}

// MARK: - Constants

private extension SettingView {
    enum Constant {
        static let versionString: String = "1.1.0"
        static let updateNoteURL = URL(string: "https://youz2me.notion.site/Livith-v-25-04-13-1d402dd0e5fc80eaacd9d3dfdc7d0aa0")!
        static let termsURL = URL(string: "https://youz2me.notion.site/Livith-v-25-11-18-1d402dd0e5fc800dab7fc177f325eade")!
    }

    enum Literals {
        static let title = "환경설정"
        static let noticeSetting = "알림 설정"
        static let updateNote = "업데이트 노트"
        static let terms = "이용약관"
        static let versionInfo = "버전정보"
        static let logout = "로그아웃"
        static let deleteAccount = "회원탈퇴"
        static let logoutAlertMessage = "정말 로그아웃 하시겠어요?"
        static let logoutAlertCancel = "취소할래요"
        static let logoutAlertConfirm = "로그아웃 할래요"
    }
}

// MARK: - Preview

#Preview {
    SettingView()
}
