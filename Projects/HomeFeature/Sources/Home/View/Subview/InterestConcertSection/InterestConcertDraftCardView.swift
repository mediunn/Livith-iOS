//
//  InterestConcertDraftCardView.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/22/26.
//  Copyright © 2026 Livith. All rights reserved.

import SwiftUI

import LivithDesignSystem

struct InterestConcertDraftCardView: View {

    // MARK: - Properties

    let posterURL: URL?
    let badgeText: String
    let titleText: String
    let dateText: String
    let locationText: String
    let bottomText: String

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: .zero) {
            topSection
            bottomSection
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - UIComponents

private extension InterestConcertDraftCardView {
    var topSection: some View {
        topSectionContent
            .padding(Card.sectionPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: Card.topSectionMinHeight)
            .background {
                RoundedRectangle(cornerRadius: Card.cornerRadius)
                    .fill(Color.livithColor(.black90))
                    .overlay {
                        RoundedRectangle(cornerRadius: Card.cornerRadius)
                            .stroke(Color.livithColor(.black80), lineWidth: Card.borderLineWidth)
                    }
                    .overlay(alignment: .bottom) {
                        seamMask
                            .offset(y: Divider.seamCoverHeight / 2)
                    }
            }
    }
    
    var bottomSection: some View {
        bottomSectionContent
            .padding(Card.sectionPadding)
            .frame(maxWidth: .infinity)
            .frame(minHeight: Card.bottomSectionMinHeight)
            .background {
                RoundedRectangle(cornerRadius: Card.cornerRadius)
                    .fill(Color.livithColor(.black90))
                    .overlay {
                        RoundedRectangle(cornerRadius: Card.cornerRadius)
                            .stroke(Color.livithColor(.black80), lineWidth: Card.borderLineWidth)
                    }
                    .overlay(alignment: .top) {
                        seamMask
                            .offset(y: -(Divider.seamCoverHeight / 2))
                    }
            }
            .overlay(alignment: .top) {
                dashedDivider
            }
    }
    
    var topSectionContent: some View {
        HStack(alignment: .top, spacing: 12) {
            posterView
            
            VStack(alignment: .leading, spacing: .zero) {
                badgeView
                
                Text(titleText)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.black5))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 4) {
                    infoRow(icon: Image.livithIcon(.durationLine), text: dateText)
                    infoRow(icon: Image.livithIcon(.locationLine), text: locationText)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, minHeight: Poster.height, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var bottomSectionContent: some View {
        Text(bottomText)
            .notosans(.body3Medium)
            .foregroundStyle(Color.livithColor(.black5))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity)
    }
    
    var posterView: some View {
        AsyncImageView(url: posterURL) {
            Image.livithImage(.interestConcertEmpty)
                .resizable()
                .scaledToFill()
        }
        .aspectRatio(Poster.aspectRatio, contentMode: .fit)
        .frame(height: Poster.height)
        .clipShape(RoundedRectangle(cornerRadius: Poster.cornerRadius))
    }

    var badgeView: some View {
        Text(badgeText)
            .notosans(.caption1Bold)
            .foregroundStyle(Color.livithColor(.black100))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.livithColor(.yellow30))
            .clipShape(Capsule())
    }
    
    func infoRow(icon: Image, text: String) -> some View {
        HStack(spacing: 4) {
            icon
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.livithColor(.black50))
                .frame(width: 20, height: 20)
            
            Text(text)
                .notosans(.body4Regular)
                .foregroundStyle(Color.livithColor(.black50))
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
    
    var dashedDivider: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: .zero, y: Divider.lineWidth / 2))
                path.addLine(to: CGPoint(x: proxy.size.width, y: Divider.lineWidth / 2))
            }
            .stroke(
                Color.livithColor(.black80),
                style: StrokeStyle(
                    lineWidth: Divider.lineWidth,
                    lineCap: .butt,
                    dash: Divider.dash
                )
            )
        }
        .frame(height: Divider.lineWidth)
        .padding(.horizontal, Card.sectionPadding)
        .offset(y: -0.5)
    }
    
    var seamMask: some View {
        Rectangle()
            .fill(Color.livithColor(.black90))
            .frame(height: Divider.seamCoverHeight)
            .padding(.horizontal, Card.sectionPadding)
    }
}

// MARK: - Constants

private extension InterestConcertDraftCardView {
    enum Card {
        static let cornerRadius: CGFloat = 16
        static let borderLineWidth: CGFloat = 1
        static let sectionPadding: CGFloat = 16
        static let topSectionMinHeight: CGFloat = 143
        static let bottomSectionMinHeight: CGFloat = 65
    }

    enum Poster {
        static let cornerRadius: CGFloat = 8
        static let aspectRatio: CGFloat = 84 / 112
        static let height: CGFloat = Card.topSectionMinHeight - (Card.sectionPadding * 2)
    }

    enum Divider {
        static let lineWidth: CGFloat = 1
        static let seamCoverHeight: CGFloat = 6
        static let dash: [CGFloat] = [4, 4]
    }
}

// MARK: - Preview

#Preview("일반 예매 오픈") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()
        
        InterestConcertDraftCardView(
            posterURL: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg"),
            badgeText: "공연 D-20",
            titleText: "원 오크 록 내한공연",
            dateText: "2025.09.13~09.14",
            locationText: "잠실 실내 체육관",
            bottomText: "일반 예매 오픈 · 9/14(일) 2:00PM"
        )
        .padding(.horizontal, 16)
    }
}

#Preview("콘서트 진행중") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()
        
        InterestConcertDraftCardView(
            posterURL: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg"),
            badgeText: "공연 D-DAY",
            titleText: "원 오크 록 내한공연",
            dateText: "2025.09.13~09.14",
            locationText: "잠실 실내 체육관",
            bottomText: "콘서트 진행중"
        )
        .padding(.horizontal, 16)
    }
}

#Preview("정보 미정") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()
        
        InterestConcertDraftCardView(
            posterURL: nil,
            badgeText: "공연 예정",
            titleText: "원 오크 록 내한 예정",
            dateText: "추후 발표",
            locationText: "장소 공개 예정",
            bottomText: "예매 오픈 예정"
        )
        .padding(.horizontal, 16)
    }
}

#Preview("긴 텍스트") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        InterestConcertDraftCardView(
            posterURL: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg"),
            badgeText: "공연 D-120",
            titleText: "ONE OK ROCK DETOX ASIA TOUR 2026 IN SEOUL SPECIAL ENCORE",
            dateText: "2026.01.17(토) 18:00 ~ 2026.01.18(일) 20:00",
            locationText: "KSPO DOME 올림픽체조경기장 및 올림픽공원 일대",
            bottomText: "일반 예매 오픈 일정이 곧 공개될 예정이며 상세 시간과 좌석별 세부 안내는 추후 공지될 수 있으니 예매 전 다시 한 번 확인해 주세요"
        )
        .padding(.horizontal, 16)
    }
}
