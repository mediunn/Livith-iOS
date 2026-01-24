//
//  InterestConcertCardContentView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct InterestConcertCardContentView: View {
    let remainDays: Int
    let date: String
    let location: String
    let title: String
    let onMoreInfoTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack {
                Spacer()
                moreInfoButton()
            }
            .padding(.top, 16)
            
            Spacer()
                .frame(minHeight: 148)
            
            remainDaysText()
                .padding(.bottom, 16)
            
            infoSection(icon: Image.livithIcon(.durationLine), text: date)
                .padding(.bottom, 4)
            
            infoSection(icon: Image.livithIcon(.locationLine), text: location)
            
            Spacer()
                .frame(height: 16)
            
            HStack {
                Text(title)
                    .notosans(.body3Medium)
                    .foregroundStyle(.livithColor(.black50))
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            .frame(height: 88)
        }
        .padding(.horizontal, 16)
    }
}

private extension InterestConcertCardContentView {
    @ViewBuilder
    func moreInfoButton() -> some View {
        VStack {
            HStack {
                Spacer()
                LivithActionButton("더 많은 정보 확인하기", type: .chevron, action: onMoreInfoTap)
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    func remainDaysText() -> some View {
        let condition = remainDays >= 0
        let dDayText: String = {
            if remainDays == 0 {
                return "D-DAY,"
            } else if condition {
                return "D-\(remainDays),"
            } else {
                return "D+\(abs(remainDays)),"
            }
        }()
        let composed: Text = {
            if condition {
                Text("콘서트까지 ")
                    .foregroundStyle(.livithColor(.white100))
                + Text(dDayText)
                    .foregroundStyle(.livithColor(.yellow30))
                + Text("\n준비를 시작해 볼까요?")
                    .foregroundStyle(.livithColor(.white100))
            } else {
                Text("콘서트 ")
                    .foregroundStyle(.livithColor(.white100))
                + Text(dDayText)
                    .foregroundStyle(.livithColor(.yellow30))
                + Text("\n알차게 즐기고 오셨나요?")
                    .foregroundStyle(.livithColor(.white100))
            }
        }()

        HStack {
            composed
                .notosans(.headSemibold)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Spacer()
        }
    }
    
    @ViewBuilder
    func infoSection(icon: Image, text: String) -> some View {
        HStack(spacing: 4) {
            icon
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
            
            Text(text)
                .notosans(.body4Regular)
                .foregroundStyle(.livithColor(.black30))
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

private extension InterestConcertCardContentView {
    enum Constants {
        static let iconSize: CGFloat = 24
    }
}

#Preview {
    ZStack {
        Color.livithColor(.black100)
        
        InterestConcertCardContentView(
            remainDays: 10,
            date: "2025.11.01~11.02",
            location: "올림픽공원 올림픽홀",
            title: "Gen Hoshino presents MAD HOPE Asia Tour in SEOUL",
            onMoreInfoTap: { print("버튼이 눌렸다.") }
        )
        .frame(height: 438)
    }
}
