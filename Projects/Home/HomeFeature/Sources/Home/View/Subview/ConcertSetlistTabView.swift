//
//  ConcertSetlistTabView.swift
//  HomeFeature
//
//  Created by 김진웅 on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import HomeDomain
import LivithFoundation

struct ConcertSetlistTabView: View {
    let setlist: Setlist?
    let songs: SetlistSongList
    let onSongTap: (Int) -> Void
    let onMoreTap: (Int) -> Void
    
    var body: some View {
        if songs.isEmpty {
            emptyView()
        } else {
            contentView()
        }
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
            
            if let setlist = self.setlist, setlist.type.isPastSetlist {
                setlistCard(setlist: setlist)
                    .padding(.top, 20)
            }
            
            VStack(spacing: .zero) {
                VStack(spacing: 12) {
                    ForEach(songs.prefix(3), id: \.self) { song in
                        LivithSongItem(
                            orderIndex: song.orderIndex,
                            title: song.title,
                            artist: song.artist,
                            onTapped: { onSongTap(song.id) }
                        )
                    }
                }
                .padding(.vertical, 20)
                
                moreButton()
            }
            .background(.livithColor(.black90))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 20)
            
            Spacer()
                .frame(height: 232)
        }
    }
    
    func titleText() -> some View {
        Text(setlist?.type.isPastSetlist == true ? "이전 콘서트에서\n어떤 노래를 불렀을까요?" : "이전 콘서트를 기반으로\n이런 노래를 예상해요")
            .notosans(.body1Semibold)
            .foregroundStyle(.livithColor(.white100))
            .multilineTextAlignment(.leading)
            .lineLimit(2)
    }
    
    func setlistCard(setlist: Setlist) -> some View {
        HStack(spacing: 16) {
            posterImageView(urlString: setlist.imageURL ?? "")
                .padding([.vertical, .leading], 16)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(setlist.title)
                    .notosans(.body2Medium)
                    .foregroundStyle(.livithColor(.black100))
                    .lineLimit(1)
                    .padding(.bottom, 4)
                
                Text(setlist.artist)
                    .notosans(.body4Regular)
                    .foregroundStyle(.livithColor(.black80))
                    .lineLimit(1)
                    .padding(.bottom, 10)
                
                HStack(spacing: 6) {
                    if setlist.venue != "" {
                        tagView(text: setlist.venue)
                    }
                    
                    tagView(text: formatDate(setlist.startDate))
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
    
    func moreButton() -> some View {
        Button {
            onMoreTap(setlist?.id ?? .zero)
        } label: {
            HStack(spacing: 8) {
                Text("더 많은 노래를 확인해 보세요")
                    .notosans(.body4Regular)
                    .foregroundStyle(.livithColor(.black50))

                Image.livithIcon(.linkGrayFill)
                    .resizable()
                    .frame(width: 12, height: 12)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .background(.livithColor(.black80))
    }
}

// MARK: - Helpers

private extension ConcertSetlistTabView {
    func formatDate(_ date: Date) -> String {
        DateFormatterService.string(from: date, type: .koreanFullDate)
    }
}

// MARK: - Constants

private extension ConcertSetlistTabView {
    enum Constants {
        static let imageSize: CGFloat = 92
    }
}
