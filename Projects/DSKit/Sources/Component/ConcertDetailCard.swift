//
//  ConcertDetailCard.swift
//  DesignSystem
//
//  Created by Youjin Lee on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Kingfisher

public struct ConcertDetailCard: View {
    
    // MARK: Property
    
    private let posterURL: URL
    private let title: String
    private let date: String
    private let artist: String
    private let status: String
    private let remainDays: Int
    
    // MARK: - LifeCycle
    
    public init(
        posterURL: URL,
        title: String,
        date: String,
        artist: String,
        status: String,
        remainDays: Int = 0
    ) {
        self.posterURL = posterURL
        self.title = title
        self.date = date
        self.artist = artist
        self.status = status
        self.remainDays = remainDays
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                posterImage()
                
                titleText()
                    .padding(.top, 6)
                
                dateText()
                    .padding(.top, 8)
                
                artistText()
                    .padding(.top, 2)
                    .padding(.bottom, 6)
            }
            .frame(width: 108)
            
            ConcertStatusChip(statusText: status, remainDays: remainDays)
                .padding(.top, 10)
                .padding(.leading, 10)
        }
        .background(Color.livithColor(.black100))
    }
}

// MARK: - ViewBuilder

private extension ConcertDetailCard {
    @ViewBuilder
    func posterImage() -> some View {
        KFImage(posterURL)
            .resizable()
            .scaledToFill()
            .frame(width: 108, height: 158)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    @ViewBuilder
    func titleText() -> some View {
        Text(title)
            .lineLimit(2)
            .truncationMode(.tail)
            .notosans(.body2Medium)
            .foregroundStyle(Color.livithColor(.white100))
    }
    
    @ViewBuilder
    func dateText() -> some View {
        Text(date)
            .lineLimit(1)
            .notosans(.caption1Semibold)
            .foregroundStyle(Color.livithColor(.black50))
    }
    
    @ViewBuilder
    func artistText() -> some View {
        Text(artist)
            .lineLimit(1)
            .notosans(.caption1Semibold)
            .foregroundStyle(Color.livithColor(.black50))
    }
}
