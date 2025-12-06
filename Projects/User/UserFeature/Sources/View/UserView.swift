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
        }
        .background {
            backgroundGradient
                .ignoresSafeArea()
        }
    }
}

// MARK: - UIComponents

private extension UserView {
    var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.init("2F3745", opacity: 1.0), Color.init("14171B", opacity: 1.0)],
            startPoint: UnitPoint(x: 0.0, y: 0.0),
            endPoint: UnitPoint(x: 0.0, y: 297.0)
        )
    }
    
    var titleText: some View {
        Text.init(
            "\(nickname)님, 반가워요!\n공연 준비 시작해볼까요?",
            highlighting: "\(nickname)",
            color: .livithColor(.white100),
            font: .notosans(.body1Semibold)
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
            .background(Color.init("29303C", opacity: 1.0))
    }
}

// MARK: - Helper Method

private extension UserView {
    func showEditView() {
        // TODO: 닉네임 수정 화면으로 이동
    }
}

// MARK: - Constants

private extension UserView {
    enum Constant {
        static let versionString: String = "2.0.0"
    }
}
