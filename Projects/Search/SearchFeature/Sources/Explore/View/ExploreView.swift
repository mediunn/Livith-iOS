//
//  ExploreView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import SearchDomain

struct ExploreView: View {
    @EnvironmentObject private var router: ExploreRouter
    @State private var currentPage: Int = 0
    @State private var banners: [Banner] = Banner.mocks
    @State private var concertSections: [ConcertSection] = ConcertSection.mocks
    
    var body: some View {
        VStack {
            ExploreLogoView()
            
            ZStack(alignment: .top) {
                ExploreSearchButton(onTap: {
                    
                    // TODO: Router를 이용한 검색 화면 이동
                    
                }).zIndex(2)
                
                ScrollView(showsIndicators: false) {
                    bannerView

                    ForEach(concertSections, id: \.id) { section in
                        ConcertSectionView(
                            concertSection: section,
                            onConcertTap: { concert in
                                
                                // TODO: Router를 이용한 콘서트 상세 화면 이동 + Concert 전달
                                
                            }
                        )
                        .padding(.top, 36)
                        .padding(.leading, 16)
                    }
                }
            }
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
