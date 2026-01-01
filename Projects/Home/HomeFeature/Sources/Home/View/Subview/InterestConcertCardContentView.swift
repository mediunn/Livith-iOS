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
        ZStack {
            moreInfoButton()
                .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: .zero) {
                Spacer()
                
                remainDaysText()
                
                dateSection()
                    .padding(.top, 16)
                
                locationSection()
                    .padding(.top, 4)
                    .padding(.bottom, 105)
            }
            
            titleText()
                .padding(.bottom, 24)
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
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func dateSection() -> some View {
        HStack(spacing: 4) {
            Image.livithIcon(.durationLine)
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
            
            Text(date)
                .notosans(.body4Regular)
                .foregroundStyle(.livithColor(.black30))
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
    
    @ViewBuilder
    func locationSection() -> some View {
        HStack(spacing: 4) {
            Image.livithIcon(.locationLine)
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
            
            Text(location)
                .notosans(.body4Regular)
                .foregroundStyle(.livithColor(.black30))
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
    
    @ViewBuilder
    func titleText() -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Spacer()
            
            HStack {
                Text(title)
                    .notosans(.body3Medium)
                    .foregroundStyle(.livithColor(.black50))
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                Spacer()
            }
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
            title: "Gen Hoshino presents\nMAD HOPE Asia Tour in SEOUL",
            onMoreInfoTap: { print("버튼이 눌렸다.") }
        )
        .frame(height: 438)
    }
}
