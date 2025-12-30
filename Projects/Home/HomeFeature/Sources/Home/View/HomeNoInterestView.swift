//
//  HomeNoInterestView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import HomeDomain

import DSKit

struct HomeNoInterestView: View {
    @Binding var nickname: String
    @Environment(\.homeCoordinator) private var coordinator
    @StateObject private var store: HomeNoInterestStore = .init()

    var body: some View {
        VStack(spacing: .zero) {
            LivithLogoHeaderView()

            ScrollView {
                VStack(spacing: .zero) {                    
                    HomeHeaderView(
                        nickname: nickname,
                        action: { coordinator?.push(to: .interest) }
                    )

                    if !store.state.isLoading && store.state.sectionList.isEmpty {
                        LivithEmptyView(text: emptyMessage)
                            .frame(minHeight: Constants.emptyStateMinHeight)
                    }

                    ForEach(store.state.sectionList, id: \.id) { section in
                        concertSectionRow(for: section)
                            .padding(.top, 28)
                            .padding(.leading, 16)
                    }

                    Spacer(minLength: Constants.emptySpaceHeight)
                }
                .background(.livithColor(.black100))
            }
            .refreshable { store.send(.onRefresh) }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(.livithColor(.black90))
    }

    private var emptyMessage: String {
        store.state.errorMessage.isEmpty ? "콘텐츠가 없습니다." : store.state.errorMessage
    }
}

// MARK: - Helper

private extension HomeNoInterestView {
    func concertSectionRow(for section: ConcertSection) -> some View {
        ConcertSectionView(
            concertSection: section,
            onConcertTap: { concert in
                coordinator?.showConcertDetail(concertID: concert.id)
            }
        )
    }
}

// MARK: - Constants

private extension HomeNoInterestView {
    enum Constants {
        static let emptySpaceHeight: CGFloat = 210
        static let emptyStateMinHeight: CGFloat = 428
    }
}
