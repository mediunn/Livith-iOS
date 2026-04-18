//
//  HomeHeaderView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/26/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct HomeHeaderView: View {
    @State private var buttonHeight: CGFloat = .zero

    let nickname: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: .zero) {
            VStack(spacing: .zero) {
                Spacer()
                
                Text("\(nickname)님,\n기다리는\n콘서트가 있나요?")
                    .notosans(.headSemibold)
                    .foregroundStyle(.livithColor(.white100))
                    .padding(.leading, 16)
                    .padding(.bottom, 28)
            }
            
            Spacer()
            
            InterestConcertSettingButton(action: action)
                .background(buttonHeightReader)
                .onPreferenceChange(InterestConcertButtonHeightPreferenceKey.self) { buttonHeight = $0 }
                .overlay(alignment: .topTrailing) {
                    if buttonHeight > .zero {
                        interestConcertCallout
                            .offset(y: buttonHeight + Constants.calloutTopSpacing)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.trailing, 16)
                .padding(.top, 24)
                .padding(.bottom, 28)
        }
        .background(Color.livithColor(.black90))
    }
}

// MARK: - Subviews

private extension HomeHeaderView {
    var buttonHeightReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: InterestConcertButtonHeightPreferenceKey.self,
                    value: proxy.size.height
                )
        }
    }

    var interestConcertCallout: some View {
        LivithCalloutView(
            "관심 콘서트 설정하고 공연 일정•셋리스트 정보 빠르게",
            style: .yellow,
            placement: .top(.trailing),
            tailInset: Constants.calloutTailInset
        )
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: false)
    }
}

// MARK: - Constants

private extension HomeHeaderView {
    enum Constants {
        static let calloutTopSpacing: CGFloat = 12
        static let calloutTailInset: CGFloat = 24
    }
}

// MARK: - Preference Key

private struct InterestConcertButtonHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    HomeHeaderView(nickname: "유지미", action: {
        print("Tapped")
    })
}
