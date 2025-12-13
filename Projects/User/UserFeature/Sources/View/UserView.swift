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
    
    // MARK: - Property
    
    private let nickname: String
    
    @State private var path = NavigationPath()
    @State private var isShowingTerms = false
    @State private var isShowingUpdateNote = false
    @State private var isShowingFeedbackForm = false
    
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

                InfoListView(title: "버전정보", type: .value("2.0.0"))
                    .padding(.bottom, 12)

                InfoListView(title: "업데이트 노트", type: .navigation, action: { showUpdateNote() })
                    .padding(.bottom, 12)

                InfoListView(title: "이용약관", type: .navigation, action: { showTerms() })
                    .padding(.bottom, 12)

                InfoListView(title: "로그아웃", type: .action, action: { logout() })
                    .padding(.bottom, 12)

                InfoListView(title: "회원탈퇴", type: .action, action: { deleteAccount() })
                    .padding(.bottom, 34)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
            .navigationDestination(for: Path.self) { destination in
                switch destination {
                case .nicknameUpdate:
                    NicknameUpdateView(store: NicknameUpdateStore())
                        .navigationBarBackButtonHidden()
                case .deleteUser:
                    DeleteUserView(store: DeleteUserStore())
                        .navigationBarBackButtonHidden()
                }
            }
        }
        .sheet(isPresented: $isShowingUpdateNote) {
            SafariView(url: URL(string: Constant.updateNoteURLString)!)
        }
        .sheet(isPresented: $isShowingTerms) {
            SafariView(url: URL(string: Constant.termsURLString)!)
        }
        .sheet(isPresented: $isShowingFeedbackForm) {
            SafariView(url: URL(string: Constant.feedbackFormURLString)!)
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
            "\(nickname)님, 반가워요!\n공연 준비 시작해볼까요?",
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
            Text("닉네임 수정")
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
}

// MARK: - Helper Method

private extension UserView {
    func showEditView() {
        path.append(Path.nicknameUpdate)
    }
    
    func showFeedbackForm() {
        isShowingFeedbackForm = true
    }
    
    func showUpdateNote() {
        isShowingUpdateNote = true
    }

    func showTerms() {
        isShowingTerms = true
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
}
