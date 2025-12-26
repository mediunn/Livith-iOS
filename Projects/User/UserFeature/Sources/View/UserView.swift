//
//  UserView.swift
//  User
//
//  Created by Youjin Lee on 12/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

public struct UserView: View {

    // MARK: - Enum

    enum OverlayType: Equatable {
        case none
        case terms
        case updateNote
        case feedbackForm
        case logout

        var sheetURL: URL? {
            switch self {
            case .terms:
                return Constant.termsURL
            case .updateNote:
                return Constant.updateNoteURL
            case .feedbackForm:
                return Constant.feedbackFormURL
            default:
                return nil
            }
        }
    }

    // MARK: - Property

    @Binding private var nickname: String

    @State private var path = NavigationPath()
    @State private var overlayType: OverlayType = .none
    @State private var showSuccessToast: Bool = false

    @Binding private var isTabBarHidden: Bool
    
    // MARK: - LifeCycle
    
    public init(nickname: Binding<String>, isTabBarHidden: Binding<Bool>) {
        self._nickname = nickname
        self._isTabBarHidden = isTabBarHidden
    }
    
    // MARK: - Body

    public var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    titleText
                    Spacer()
                    editButton
                }
                .padding(.top, 168)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

                divideLine
                    .padding(.bottom, 20)

                feedbackButton
                    .frame(height: 84)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                InfoListView(title: Literals.versionInfo, type: .value(Constant.versionString))
                    .padding(.bottom, 12)

                InfoListView(title: Literals.updateNote, type: .navigation, action: { showUpdateNote() })
                    .padding(.bottom, 12)

                InfoListView(title: Literals.terms, type: .navigation, action: { showTerms() })
                    .padding(.bottom, 12)

                InfoListView(title: Literals.logout, type: .action, action: { logout() })
                    .padding(.bottom, 12)

                InfoListView(title: Literals.deleteAccount, type: .action, action: { deleteAccount() })
                    .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
            .navigationDestination(for: Path.self) { destination in
                switch destination {
                case .nicknameUpdate:
                    NicknameUpdateView(
                        store: NicknameUpdateStore(),
                        onDismiss: { path.removeLast() },
                        onSuccess: {
                            path.removeLast()
                            withAnimation { showSuccessToast = true }
                        }
                    )
                    .navigationBarBackButtonHidden()
                case .deleteUser:
                    DeleteUserView(
                        store: DeleteUserStore(),
                        onDismiss: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                }
            }
            .livithToast(
                isPresented: $showSuccessToast,
                type: .success,
                message: Literals.toastSuccess
            )
        }
        .sheet(isPresented: isSheetPresented) {
            if let url = overlayType.sheetURL {
                SafariView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .overlay {
            logoutConfirmDialog
        }
        .animation(.easeInOut(duration: 0.3), value: overlayType)
        .onChange(of: path) { _, newPath in
            Task { @MainActor in
                isTabBarHidden = !newPath.isEmpty
            }
        }
    }
}

// MARK: - UIComponents

private extension UserView {
    var backgroundGradient: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.init(hex: "2F3745"), Color.init(hex: "14171B")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 297)
                
                Color.livithColor(.black100)
            }
        }
        .ignoresSafeArea()
    }
    
    var titleText: some View {
        Text.init(
            String(format: Literals.titleFormat, nickname),
            highlighting: "\(nickname)",
            color: .livithColor(.white100),
            font: .notosans(.headSemibold)
        )
        .notosans(.headMedium)
        .foregroundStyle(Color.livithColor(.black30))
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
    }

    var editButton: some View {
        Button {
            showEditView()
        } label: {
            Text(Literals.editNickname)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black5))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
        }
        .background(Color.livithColor(.black80))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    var divideLine: some View {
        Divider()
            .frame(height: 5)
            .background(Color.init(hex: "29303C", opacity: 1.0))
    }
    
    var feedbackButton: some View {
        Button {
            showFeedbackForm()
        } label: {
            Image.livithImage(.feedback)
                .resizable()
                .scaledToFill()
        }
    }

    @ViewBuilder
    var logoutConfirmDialog: some View {
        if overlayType == .logout {
            LivithConfirmDialog(
                message: Literals.logoutAlertMessage,
                confirmTitle: Literals.logoutAlertConfirm,
                cancelTitle: Literals.logoutAlertCancel,
                onConfirm: {
                    overlayType = .none
                    performLogout()
                },
                onCancel: {
                    overlayType = .none
                }
            )
        }
    }
}

// MARK: - Helper

private extension UserView {
    var isSheetPresented: Binding<Bool> {
        Binding(
            get: { overlayType.sheetURL != nil },
            set: { if !$0 { overlayType = .none } }
        )
    }
}

// MARK: - Helper Method

private extension UserView {
    func showEditView() {
        path.append(Path.nicknameUpdate)
    }

    func showFeedbackForm() {
        overlayType = .feedbackForm
    }

    func showUpdateNote() {
        overlayType = .updateNote
    }

    func showTerms() {
        overlayType = .terms
    }

    func logout() {
        overlayType = .logout
    }

    func performLogout() {
        // TODO: 로그아웃 처리
    }

    func deleteAccount() {
        path.append(Path.deleteUser)
    }

}

// MARK: - Constants

private extension UserView {
    enum Path: Hashable {
        case nicknameUpdate
        case deleteUser
    }

    enum Constant {
        static let versionString: String = "2.0.0"
        static let updateNoteURL = URL(string: "https://youz2me.notion.site/Livith-v-25-04-13-1d402dd0e5fc80eaacd9d3dfdc7d0aa0")!
        static let termsURL = URL(string: "https://youz2me.notion.site/Livith-v-25-11-18-1d402dd0e5fc800dab7fc177f325eade")!
        static let feedbackFormURL = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSe-d5MhQrwsRRrk9isYiYVw1afI7a60Xm0IHbxmmAHe8AUiMA/viewform")!
    }

    enum Literals {
        static let titleFormat = "%@님, 반가워요!\n공연 준비 시작해볼까요?"
        static let editNickname = "닉네임 수정"
        static let versionInfo = "버전정보"
        static let updateNote = "업데이트 노트"
        static let terms = "이용약관"
        static let logout = "로그아웃"
        static let deleteAccount = "회원탈퇴"
        static let toastSuccess = "닉네임이 수정되었어요"
        static let logoutAlertMessage = "정말 로그아웃 하시겠어요?"
        static let logoutAlertCancel = "취소할래요"
        static let logoutAlertConfirm = "로그아웃 할래요"
    }
}
