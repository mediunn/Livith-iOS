//
//  InterestConcertCardView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import Kingfisher

struct InterestConcertCardView: View {
    let posterURL: URL?
    let remainDays: Int
    let date: String
    let location: String
    let title: String
    let onMoreInfoTap: () -> Void
    
    init(
        posterURL: URL?,
        remainDays: Int,
        date: String,
        location: String,
        title: String,
        onMoreInfoTap: @escaping () -> Void = {}
    ) {
        self.posterURL = posterURL
        self.remainDays = remainDays
        self.date = date
        self.location = location
        self.title = title
        self.onMoreInfoTap = onMoreInfoTap
    }
    
    var body: some View {
        ZStack {
            Color.livithColor(.black90)
            
            InterestConcertCardContentView(
                remainDays: remainDays,
                date: date,
                location: location,
                title: title,
                onMoreInfoTap: onMoreInfoTap
            )
            .background(
                concertPosterImageView()
            )
            .frame(height: 438)
            .padding(24)
        }
    }
}

private extension InterestConcertCardView {
    @ViewBuilder
    func concertPosterImageView() -> some View {
        ZStack{
            KFImage(posterURL)
                .resizable()
                .placeholder {
                    Color.livithColor(.black80)
                }
                .overlay {
                    BackgroundGradientView()
                }
            
            VStack {
                Spacer()
                
                line()
                    .padding(.bottom, 82)
            }
        }
        .mask { notchedCardShape }
        .overlay(
            notchedCardShape
                .stroke(Color(hex: "2f3745"), lineWidth: 1)
        )
        .shadow(radius: 5)
    }
    
    var notchedCardShape: some Shape {
        NotchedCardShape(cornerRadius: 8, notchSize: .init(width: 18, height: 36), notchBottomOffset: 64)
    }
    
    @ViewBuilder
    func line() -> some View {
        HorizontalLineShape()
            .stroke(
                Color.livithColor(.black50),
                style: StrokeStyle(
                    lineWidth: Constants.lineWidth,
                    lineCap: .butt,
                    dash: [4, 4]
                )
            )
            .frame(height: Constants.lineWidth)
    }
}

// MARK: - Constants

private extension InterestConcertCardView {
    enum Constants {
        static let lineWidth: CGFloat = 1.5
    }
}

#Preview {
    InterestConcertCardView(
        posterURL: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg"),
        remainDays: 10,
        date: "2025.11.01~11.02",
        location: "올림픽공원 올림픽홀올림픽공원 올림픽홀올림픽공원 올림픽홀올림픽공원 올림픽홀올림픽공원 올림픽홀올림픽공원 올림픽홀",
        title: "Gen Hoshino presentsMAD HOPE Asia Tour in SEOULGen Hoshino presentsMAD HOPE Asia Tour in SEOUL"
    )
}
