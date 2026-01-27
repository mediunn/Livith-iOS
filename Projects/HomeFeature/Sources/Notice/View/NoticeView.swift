//
//  NoticeView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 1/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

// MARK: - NoticeView

public struct NoticeView: View {

    // MARK: - Property

    private let onBack: () -> Void
    private let onSettingTap: () -> Void

    // MARK: - Initializer

    public init(
        onBack: @escaping () -> Void,
        onSettingTap: @escaping () -> Void
    ) {
        self.onBack = onBack
        self.onSettingTap = onSettingTap
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            navigationBar

            noticeList
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
    }
}

// MARK: - UIComponents

private extension NoticeView {
    var navigationBar: some View {
        HStack(spacing: 4) {
            Button(action: onBack) {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 36, height: 36)
            }
            .padding(.leading, 16)

            Text(Literals.title)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(1)

            Spacer()

            LivithTextButton(
                Literals.settingButton,
                color: .livithColor(.white100),
                action: onSettingTap
            )
            .padding(.trailing, 16)
        }
        .frame(height: 66)
        .padding(.top, 12)
    }

    var infoText: some View {
        HStack {
            Text(Literals.infoMessage)
                .notosans(.body4Semibold)
                .foregroundStyle(Color.livithColor(.black30))

            Spacer()
        }
    }

    var noticeList: some View {
        ScrollView {
            infoText
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            
            LazyVStack(spacing: 12) {
                // TODO: 실제 데이터 연결 필요
                NoticeItemView(
                    title: "(광고) 추천 콘서트를 가져왔어요 🎵",
                    description: "선택하신 취향을 바탕으로\n지금 가장 잘 맞는 콘서트 하나를 골라봤어요!",
                    timeAgo: "5시간 전",
                    state: .normal,
                    action: {}
                )

                NoticeItemView(
                    title: "(광고) 추천 콘서트를 가져왔어요 🎵",
                    description: "선택하신 취향을 바탕으로\n지금 가장 잘 맞는 콘서트 하나를 골라봤어요!",
                    timeAgo: "5시간 전",
                    state: .read,
                    action: {}
                )
                
                NoticeItemView(
                    title: "(광고) 추천 콘서트를 가져왔어요 🎵",
                    description: "선택하신 취향을 바탕으로\n지금 가장 잘 맞는 콘서트 하나를 골라봤어요!",
                    timeAgo: "5시간 전",
                    state: .read,
                    action: {}
                )
                
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Constants

private extension NoticeView {
    enum Literals {
        static let title = "알림"
        static let settingButton = "알림 설정"
        static let infoMessage = "알림은 90일 이후 순차적으로 삭제돼요."
    }
}

// MARK: - Preview

#Preview {
    NoticeView(
        onBack: {},
        onSettingTap: {}
    )
}
