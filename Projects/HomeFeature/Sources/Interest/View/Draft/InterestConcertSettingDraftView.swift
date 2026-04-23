//
//  InterestConcertSettingDraftView.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct InterestConcertSettingDraftView: View {

    // MARK: - Property

    @State private var store: InterestConcertSettingStore

    // MARK: - Initializer

    init(
        mode: InterestConcertSettingMode,
        userInterestConcertList: [Concert] = []
    ) {
        _store = State(
            wrappedValue: InterestConcertSettingStore(
                mode: mode,
                userInterestConcertList: userInterestConcertList
            )
        )
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            navigationBar

            topSection

            gridSection
        }
        .background(Color.livithColor(.black100))
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .simultaneousGesture(TapGesture().onEnded { _ in
            store.send(.setSearchFocused(false))
        })
        .safeAreaInset(edge: .bottom) {
            bottomSection
        }
    }
}

// MARK: - UIComponents

private extension InterestConcertSettingDraftView {
    var topSection: some View {
        VStack(spacing: .zero) {
            if !store.state.isSearchFocused {
                guideSection
            }

            searchTextField
                .padding(.top, store.state.isSearchFocused ? Constants.searchFocusedTopPadding : Constants.searchDefaultTopPadding)
                .padding(.horizontal, Constants.horizontalPadding)
        }
    }

    var gridSection: some View {
        InterestConcertSelectionGridView(
            concertList: store.state.filteredConcertList,
            selectedConcertIDList: store.state.selectedConcertIDList,
            onConcertTap: { store.send(.toggleConcertSelection($0)) },
            onScroll: { store.send(.setSearchFocused(false)) }
        )
        .padding(.top, 12)
    }

    var bottomSection: some View {
        InterestConcertSelectionBottomSectionView(
            selectedConcertList: store.state.selectedConcertList,
            ctaTitle: store.state.mode.ctaTitle,
            isCTAEnabled: store.state.isCTAEnabled,
            onRemoveSelectedConcert: { store.send(.removeSelectedConcert($0)) },
            // TODO: 실제 관심 콘서트 저장/변경 플로우가 확정되면 CTA 액션을 연결한다.
            onSubmit: {}
        )
    }

    var navigationBar: some View {
        LivithNavigationView(
            type: .back(
                title: store.state.mode.navigationTitle,
                // TODO: 실제 화면 연결 시 뒤로가기 액션을 주입하거나 coordinator와 연결한다.
                onBack: {}
            )
        )
    }

    var guideSection: some View {
        HStack(alignment: .top, spacing: .zero) {
            Text(Literals.guideTitle)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .multilineTextAlignment(.leading)

            Spacer()

            Text(selectedCountText)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
        }
        .padding(.top, Constants.guideTopPadding)
        .padding(.horizontal, Constants.horizontalPadding)
    }

    var searchTextField: some View {
        LivithTextField(
            text: searchText,
            isFocused: searchFocus,
            type: .search,
            placeholder: Literals.searchPlaceholder,
            onClear: { store.send(.clearSearchText) }
        )
    }
}

// MARK: - Helpers

private extension InterestConcertSettingDraftView {
    var selectedCountText: String {
        "\(store.state.selectedConcertCount)개 선택"
    }

    var searchText: Binding<String> {
        Binding(
            get: { store.state.searchText },
            set: { store.send(.updateSearchText($0)) }
        )
    }

    var searchFocus: Binding<Bool> {
        Binding(
            get: { store.state.isSearchFocused },
            set: { store.send(.setSearchFocused($0)) }
        )
    }
}

private extension InterestConcertSettingDraftView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let guideTopPadding: CGFloat = 30
        static let searchDefaultTopPadding: CGFloat = 30
        static let searchFocusedTopPadding: CGFloat = 12
    }

    enum Literals {
        static let guideTitle = "소식을 받을 콘서트를\n선택해 주세요"
        static let searchPlaceholder = "찾고 있는 콘서트나 가수를 검색하세요"
    }
}

// MARK: - Preview

#Preview("Initial Setup") {
    InterestConcertSettingDraftView(
        mode: .initialSetup
    )
    .background(Color.livithColor(.black100))
}

#Preview("Update") {
    InterestConcertSettingDraftView(
        mode: .update,
        userInterestConcertList: [
            Concert(
                id: 1,
                title: "IU 2026 TOUR H.E.R.",
                artist: "IU",
                status: .upcoming,
                daysLeft: 1,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86_400),
                posterURL: URL(string: "https://fastly.picsum.photos/id/1023/216/316.jpg?hmac=Wunm3hRG7WiE7puCI0_-RyR4Do-XrvPTOd02kuc1ktw")!,
                venue: "KSPO DOME",
                ticketSite: "인터파크",
                ticketURL: URL(string: "https://example.com/ticket-1"),
                introduction: "Draft 관심 콘서트 데이터",
                label: nil
            )
        ]
    )
    .background(Color.livithColor(.black100))
}
