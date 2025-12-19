//
//  ExploreView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ExploreView: View {
    @EnvironmentObject private var router: ExploreRouter
    @State private var currentPage: Int = 0
    @State private var banners: [Banner] = Banner.mocks
    
    var body: some View {
        VStack {
            ExploreLogoView()
            
            ZStack(alignment: .top) {
                ExploreSearchButton()
                    .zIndex(2)
                
                ScrollView {
                    bannerView
                }
            }
            
            Spacer()
        }
        .background(Color.livithColor(.black100))
    }
}

// MARK: - UIComponents

private extension ExploreView {
    var bannerView: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                    BannerCell(
                        imageURL: banner.imageURL,
                        category: banner.category,
                        title: banner.title,
                        description: banner.description
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 365)
            
            BannerPageIndicator(
                currentPage: currentPage,
                pageCount: banners.count
            )
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    ExploreView()
}
