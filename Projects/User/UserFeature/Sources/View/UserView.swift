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
    
    
    // MARK: - LifeCycle
    
    public init(nickname: String) {
        self.nickname = nickname
    }
    
    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 46) {
                titleText
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
        .background(backgroundGradient.ignoresSafeArea())
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
    }
    
    var editButton: some View {
        Button {
            showEditView()
        } label: {
            Text("닉네임 수정")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black5))
                .padding(.vertical, 8)
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
        // TODO: 닉네임 수정 화면으로 이동
    }
    
    func showFeedbackForm() {
        // TODO: 폼 화면으로 이동
    }
    
    func showUpdateNote() {
        
    }
    
    func showTerms() {
        
    }
    
    func logout() {
        
    }
    
    func deleteAccount() {
        
    }
}

// MARK: - Constants

private extension UserView {
    enum Constant {
        static let versionString: String = "2.0.0"
    }
}

#Preview {
    UserView(nickname: "유지미")
}
