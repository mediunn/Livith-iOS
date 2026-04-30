//
//  InterestConcertGridView.swift
//  HomeFeature
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DisplaySupport
import Domain
import LivithDesignSystem

struct InterestConcertGridView: View {

    // MARK: - Properties

    @Environment(\.homeCoordinator) private var coordinator
    @StateObject private var store: InterestConcertListStore = .init()

    private let onChangeTap: () -> Void

    // MARK: - Initializer

    init(onChangeTap: @escaping () -> Void = {}) {
        self.onChangeTap = onChangeTap
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            headerView

            contentView
                .padding(.top, 20)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
        .onAppear { store.send(.onAppear) }
    }
}

// MARK: - UIComponents

private extension InterestConcertGridView {
    var headerView: some View {
        HStack(spacing: 4) {
            Button {
                coordinator?.pop()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 36, height: 36)
            }

            Text("나의 관심 콘서트")
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Spacer()

            changeButton
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
        .frame(height: 66)
    }

    var changeButton: some View {
        Button(action: onChangeTap) {
            Text("변경하기")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    Capsule()
                        .strokeBorder(Color.livithColor(.black90), lineWidth: 1)
                }
        }
    }

    @ViewBuilder
    var contentView: some View {
        if store.state.isInitialLoading {
            loadingView
        } else {
            gridView
        }
    }

    var loadingView: some View {
        VStack {
            Spacer()

            ProgressView()
                .tint(Color.livithColor(.white100))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var gridView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
                spacing: 24
            ) {
                ForEach(store.state.interestConcertList, id: \.id) { interestConcert in
                    concertCard(for: interestConcert)
                }
            }

            if store.state.isLoadingMore {
                ProgressView()
                    .tint(Color.livithColor(.white100))
                    .padding(.vertical, 16)
            }
        }
    }

    func concertCard(for interestConcert: InterestConcert) -> some View {
        let concert = interestConcert.concert

        return LivithCard(
            imageURL: concert.posterURL,
            title: InterestConcertDisplayText.title(for: interestConcert),
            subtitle: InterestConcertDisplayText.dateRange(for: interestConcert),
            secondaryText: concert.artist,
            badge: .status(text: InterestConcertDisplayText.badge(for: interestConcert), remainDays: nil),
            onTap: { coordinator?.showConcertDetail(concertID: concert.id) }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .onAppear {
            if interestConcert.id == store.state.interestConcertList.last?.id {
                store.send(.loadNextPage)
            }
        }
    }
}
