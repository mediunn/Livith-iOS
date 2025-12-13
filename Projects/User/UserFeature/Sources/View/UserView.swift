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

    enum SheetType: Identifiable {
        case terms
        case updateNote
        case feedbackForm

        var id: Self { self }

        var url: URL {
            switch self {
            case .terms:
                return URL(string: Constant.termsURLString)!
            case .updateNote:
                return URL(string: Constant.updateNoteURLString)!
            case .feedbackForm:
                return URL(string: Constant.feedbackFormURLString)!
            }
        }
    }

    enum ToastType {
        case none
        case nicknameUpdateSuccess
    }

    // MARK: - Property

    private let nickname: String

    @State private var path = NavigationPath()
    @State private var activeSheet: SheetType?
    @State private var toastType: ToastType = .none

    @Binding private var isTabBarHidden: Bool
    
    // MARK: - LifeCycle
    
    public init(nickname: String, isTabBarHidden: Binding<Bool>) {
        self.nickname = nickname
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
                    .padding(.bottom, 34)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
            .navigationDestination(for: Path.self) { destination in
                switch destination {
                case .nicknameUpdate:
                    NicknameUpdateView(
                        store: NicknameUpdateStore(),
                        onSuccess: {
                            withAnimation { toastType = .nicknameUpdateSuccess }
                        }
                    )
                    .navigationBarBackButtonHidden()
                case .deleteUser:
                    DeleteUserView(store: DeleteUserStore())
                        .navigationBarBackButtonHidden()
                }
            }
            .overlay(alignment: .top) {
                if toastType != .none {
                    toastView
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { toastType = .none }
                            }
                        }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: toastType)
        }
        .sheet(item: $activeSheet) { sheet in
            SafariView(url: sheet.url)
        }
        .onAppear {
            isTabBarHidden = false
        }
    }
}

// MARK: - UIComponents

private extension UserView {
    var backgroundGradient: some View {
        GeometryReader { geo in
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
    var toastView: some View {
        switch toastType {
        case .none:
            EmptyView()
        case .nicknameUpdateSuccess:
            LivithToast(type: .success, message: Literals.toastSuccess)
        }
    }
}

// MARK: - Helper Method

private extension UserView {
    func showEditView() {
        path.append(Path.nicknameUpdate)
    }

    func showFeedbackForm() {
        activeSheet = .feedbackForm
    }

    func showUpdateNote() {
        activeSheet = .updateNote
    }

    func showTerms() {
        activeSheet = .terms
    }

    func logout() {

    }

    func deleteAccount() {
        isTabBarHidden = true
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
        static let updateNoteURLString: String = "https://youz2me.notion.site/Livith-v-25-04-13-1d402dd0e5fc80eaacd9d3dfdc7d0aa0"
        static let termsURLString: String = "https://youz2me.notion.site/Livith-v-25-11-18-1d402dd0e5fc800dab7fc177f325eade"
        static let feedbackFormURLString: String = "https://docs.google.com/forms/d/e/1FAIpQLSe-d5MhQrwsRRrk9isYiYVw1afI7a60Xm0IHbxmmAHe8AUiMA/viewform"
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
    }
}
