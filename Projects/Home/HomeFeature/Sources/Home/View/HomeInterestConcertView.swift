//
//  HomeInterestConcertView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeDomain

struct HomeInterestConcertView: View {
    @Environment(\.homeCoordinator) private var coordinator
    @State private var selectedTab: InterestConcertTab = .schedule
    
    private let posterURL: URL? = URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg")
    private let remainDays: Int = 10
    private let date: String = "2025.11.01~11.02"
    private let location: String = "올림픽공원 올림픽홀"
    private let title: String = "Gen Hoshino presents MAD HOPEAsia Tour in SEOUL"
    private let concertScheduleList: ConcertScheduleList = .mock()
    
    var body: some View {
        VStack(spacing: .zero) {
            LivithLogoHeaderView()
            
            ScrollView {
                VStack(spacing: .zero) {
                    textHeaderView
                    
                    InterestConcertCardView(
                        posterURL: posterURL,
                        remainDays: remainDays,
                        date: date,
                        location: location,
                        title: title
                    )
                    .frame(minHeight: 486)
                    
                    SegmentTabBar(
                        segmentTitles: InterestConcertTab.allCases.map { $0.title },
                        selectedIndex: selectedTab.rawValue,
                        onTabSelected: updateSelectedTab(from:)
                    )
                    
                    if selectedTab == .schedule {
                        ConcertScheduleTabView(schedules: concertScheduleList)
                    } else {
                        Spacer()
                            .frame(height: 1000)
                    }
                }
            }
        }
        .background(.livithColor(.black100))
    }
}

// MARK: - Subviews

private extension HomeInterestConcertView {
    var textHeaderView: some View {
        HStack(spacing: .zero) {
            Text("나의 관심 콘서트")
                .notosans(.headSemibold)
                .foregroundStyle(.livithColor(.white100))
                .padding(.leading, 16)
            
            Spacer()
            
            Button {
                
            } label: {
                Text("수정하기")
                    .notosans(.body4Regular)
                    .foregroundStyle(.livithColor(.black50))
                    .padding(8)
            }
            .padding(.top, 20)
            .padding([.bottom, .trailing], 16)
        }
    }
}

// MARK: - Helpers

private extension HomeInterestConcertView {
    func updateSelectedTab(from index: Int) {
        if let tab = InterestConcertTab(rawValue: index) {
            selectedTab = tab
        }
    }
}

#Preview {
    HomeInterestConcertView()
}
