//
//  HomeConcertSectionView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Domain

import LivithDesignSystem

struct HomeConcertSectionView: View {
    @Binding var nickname: String
    @Environment(\.homeCoordinator) private var coordinator
    @ObservedObject private var store: HomeStore

    init(nickname: Binding<String>, store: HomeStore) {
        self._nickname = nickname
        self.store = store
    }

    var body: some View {
        VStack(spacing: .zero) {
            LivithNavigationView(type: .logo(
                hasNewNotice: store.state.hasNewNotice,
                onNoticeTap: { coordinator?.push(to: .notice) }
            ))

            ScrollView {
                VStack(spacing: .zero) {                    
                    HomeHeaderView(
                        nickname: nickname,
                        action: { coordinator?.push(to: .interest) }
                    )

                    if !store.state.isSectionsLoading && store.state.sectionList.isEmpty {
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
            .refreshable { store.send(.onRefreshSections) }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(.livithColor(.black90))
    }

    private var emptyMessage: String {
        store.state.errorMessage.isEmpty ? "콘텐츠가 없습니다." : store.state.errorMessage
    }
}

// MARK: - Helper

private extension HomeConcertSectionView {
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

private extension HomeConcertSectionView {
    enum Constants {
        static let emptySpaceHeight: CGFloat = 210
        static let emptyStateMinHeight: CGFloat = 428
    }
}
