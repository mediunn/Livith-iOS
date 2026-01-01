//
//  ConcertSetlistTabView.swift
//  HomeFeature
//
//  Created by 김진웅 on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ConcertSetlistTabView: View {
    let selist: SetlistItem
    
    var body: some View {
        contentView()
    }
}

// MARK: - Subviews

private extension ConcertSetlistTabView {
    func emptyView() -> some View {
        VStack {
            Spacer()
                .frame(height: 200)
            
            LivithEmptyView(text: "셋리스트가 따로 없어요")
                .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 360)
        }
    }
    
    func contentView() -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            titleText()
                .padding(.top, 24)
            
            concertCard(concert: .sample)
                .padding(.top, 20)
            
            Spacer()
                .frame(height: 1000)
        }
        .padding(.horizontal, 16)
    }
    
    func titleText() -> some View {
        Text("이전 콘서트에서\n어떤 노래를 불렀을까요?")
            .notosans(.body1Semibold)
            .foregroundStyle(.livithColor(.white100))
            .multilineTextAlignment(.leading)
            .lineLimit(2)
    }
    
    func concertCard(concert: SetlistItem) -> some View {
        HStack(spacing: 16) {
            posterImageView(urlString: concert.posterURL)
                .padding([.vertical, .leading], 12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(concert.title)
                    .notosans(.body1Semibold)
                    .foregroundStyle(.livithColor(.black100))
                    .lineLimit(1)
                
                Text(concert.singer)
                    .notosans(.body2Regular)
                    .foregroundStyle(.livithColor(.black80))
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    tagView(text: concert.location)
                    tagView(text: concert.date)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 12)
        }
        .background(.livithColor(.white100))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    func posterImageView(urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { image in
            image
                .resizable()
                .aspectRatio(1, contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(.livithColor(.black80))
        }
        .frame(height: Constants.imageSize)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    func tagView(text: String) -> some View {
        Text(text)
            .notosans(.caption2Regular)
            .foregroundStyle(.livithColor(.black50))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.livithColor(.black100))
            )
    }
}
// MARK: - Constants

private extension ConcertSetlistTabView {
    enum Constants {
        static let imageSize: CGFloat = 92
    }
}

#Preview {
    ScrollView {
        ConcertSetlistTabView(selist: .sample)
    }
    .background(.livithColor(.black100))
}
