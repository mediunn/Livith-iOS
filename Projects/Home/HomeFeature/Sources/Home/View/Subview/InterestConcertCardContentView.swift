//
//  InterestConcertCardContentView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct InterestConcertCardContentView: View {
    let remainDays: Int
    let date: String
    let location: String
    let title: String
    let onMoreInfoTap: () -> Void
    
    var body: some View {        
        ZStack(alignment: .topTrailing) {
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
                    .frame(height: 40)
                
                Text(title)
                    .notosans(.body3Medium)
                    .foregroundStyle(.livithColor(.black50))
                    .lineLimit(2)
                    .truncationMode(.tail)

                Spacer()
                    .frame(minHeight: 24, maxHeight: 32)
            }
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
                
                Button(action: onMoreInfoTap) {
                    HStack(spacing: 4) {
                        Text("더 많은 정보 확인하기")
                            .notosans(.caption1Semibold)
                            .foregroundStyle(.livithColor(.white100))
                        
                        Image.livithIcon(.rightLineDefault)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(.livithColor(.black100))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .livithColor(.white100), radius: 8)
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func remainDaysText() -> some View {
        let text = "콘서트까지 D-\(remainDays)\n알차게 즐기고 오셨나요?"
        HStack {
            Text(text)
                .notosans(.headSemibold)
                .foregroundStyle(.livithColor(.white100))
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
