//
//  SearchView.swift
//  Search
//
//  Created by Youjin Lee on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Combine
import SwiftUI

import DisplaySupport
import Domain
import LivithDesignSystem

import Amplitude

struct SearchView: View {

    // MARK: - Property

    @Environment(\.searchCoordinator) private var coordinator
    @ObservedObject private var store: SearchStore

    @State private var showError: Bool = false
    @State private var showFilter: Bool = false
    @State private var showSort: Bool = false

    // MARK: - Initializer

    init(store: SearchStore) {
        self.store = store

        store.send(.viewDidLoad)
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            searchBarView
                .padding(.bottom, 14)

            ScrollView {
                filterView
                    .padding(.bottom, 16)
                    .zIndex(100)

                if store.state.searchedConcertList.isEmpty {
                    searchEmptyView
                        .padding(.top, 183)
                } else {
                    searchResultView
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: store.state.searchedConcertList.map { $0.id })
        .background(Color.livithColor(.black100).ignoresSafeArea())
        .onChange(of: store.state.errorMessage) { _, newValue in
            showError = !newValue.isEmpty
        }
        .crossDissolve(isPresented: $showError, dismissOnTapOutside: true) {
            LivithModal(
                type: .error(title: "오류가 발생했어요!", message: store.state.errorMessage),
                onConfirm: { showError = false }
            )
        }
        .livithSheet(
            isPresented: $showFilter,
            detents: [.fraction(366.0 / 812.0)]
        ) {
            FilterBottomSheetView(
                selectedGenreList: Binding(
                    get: { store.state.selectedGenreList },
                    set: { newGenres in
                        store.send(.settingButtonTapped(genres: newGenres, status: store.state.selectedStatusList))
                    }
                ),
                selectedStatusList: Binding(
                    get: { store.state.selectedStatusList },
                    set: { newStatus in
                        store.send(.settingButtonTapped(genres: store.state.selectedGenreList, status: newStatus))
                    }
                ),
                showFilter: $showFilter
            )
        }
    }
}

// MARK: - UIComponents

private extension SearchView {
    var genreSelectedText: String? {
        guard !store.state.selectedGenreList.isEmpty else { return nil }
        let genreNames = store.state.selectedGenreList.map { $0.genreText }
        return setButtonText(input: genreNames)
    }

    var statusSelectedText: String? {
        guard !store.state.selectedStatusList.isEmpty else { return nil }
        let statusNames = store.state.selectedStatusList.map { $0.filterText }
        return setButtonText(input: statusNames)
    }

    var searchBarView: some View {
        HStack(alignment: .center) {
            Button {
                hideKeyboard()
                coordinator?.pop()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
            }

            LivithTextField(
                text: Binding(
                    get: { store.state.searchMessage },
                    set: { store.send(.updateSearchMessage($0)) }
                ),
                type: .search,
                placeholder: "찾고 있는 콘서트나 가수를 검색하세요",
                onSubmit: {
                    performSearch()
                    hideKeyboard()
                },
                onChange: {
                    if isCompleteKorean() { performSearch() }
                },
                onClear: {
                    store.send(.clearButtonTapped)
                }
            )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    var filterView: some View {
        HStack(alignment: .center, spacing: 0) {
            LivithFilterButton(
                style: .genre,
                selectedText: genreSelectedText,
                action: { hideKeyboard(); showFilter = true },
                onClear: {
                    store.send(.settingButtonTapped(genres: [], status: store.state.selectedStatusList))
                }
            )
            .padding(.leading, 16)

            LivithFilterButton(
                style: .status,
                selectedText: statusSelectedText,
                action: { hideKeyboard(); showFilter = true },
                onClear: {
                    store.send(.settingButtonTapped(genres: store.state.selectedGenreList, status: []))
                }
            )
            .padding(.leading, 8)

            Spacer()

            sortButton
                .padding(.trailing, 16)
        }
    }

    var sortButton: some View {
        Button {
            showSort.toggle()
        } label: {
            HStack(alignment: .center, spacing: 4) {
                Text(store.state.sortState == .latest ? "최신순" : "가나다순")
                    .notosans(.caption1Bold)
                    .foregroundStyle(Color.livithColor(.white100))

                Image.livithIcon(showSort ? .upLineSmall : .down1_5LineSmall)
                    .renderingMode(.template)
                    .foregroundStyle(Color.livithColor(.white100))
            }
        }
        .overlay(alignment: .topTrailing) {
            if showSort {
                sortView
                    .offset(y: 30)
                    .zIndex(1000)
            }
        }
    }

    var sortView: some View {
        VStack(alignment: .center, spacing: 0) {
            LivithOptionButton("최신순", isSelected: store.state.sortState == .latest) {
                AmplitudeService.shared.trackEvent(tag: .click(.sortLatest))
                store.send(.sortStateChanged(.latest))
                showSort = false
            }
            .padding(.bottom, 8)

            LivithOptionButton("가나다순", isSelected: store.state.sortState == .alphabetical) {
                AmplitudeService.shared.trackEvent(tag: .click(.sortAlphabetical))
                store.send(.sortStateChanged(.alphabetical))
                showSort = false
            }
        }
        .fixedSize()
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 16,
                bottomLeadingRadius: 16,
                bottomTrailingRadius: 16,
                topTrailingRadius: 0
            )
            .fill(Color.livithColor(.black90))
            .strokeBorder(Color.livithColor(.black80), lineWidth: 1)
            .shadow(color: .black.opacity(0.25), radius: 5.2)
        }
    }

    @ViewBuilder
    var searchEmptyView: some View {
        LivithEmptyView(text: "검색 결과가 없어요")

        Spacer()
    }

    var searchResultCell: some View {
        ForEach(store.state.searchedConcertList, id: \.id) { concert in
            LivithCard(
                imageURL: concert.posterURL,
                title: ConcertDisplayHelper.title(for: concert),
                subtitle: concert.formattedStartDate,
                secondaryText: concert.artist,
                badge: .status(text: ConcertDisplayHelper.statusBadge(for: concert), remainDays: nil),
                onTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.searchCell))
                    hideKeyboard()
                    coordinator?.showConcertDetail(concertID: concert.id)
                }
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .onAppear {
                if concert.id == store.state.searchedConcertList.last?.id {
                    store.send(.loadNextPage)
                }
            }
        }
    }

    var searchResultView: some View {
        VStack(spacing: 0) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
                spacing: 16
            ) {
                searchResultCell
            }
            .padding(.horizontal, 16)

            if store.state.isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
    }


}

// MARK: - Helper Method

private extension SearchView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func isCompleteKorean() -> Bool {
        let message = store.state.searchMessage
        guard let lastChar = message.last else { return false }

        return !String(lastChar).contains(/[ㄱ-ㅎㅏ-ㅣ]/)
    }

    func performSearch() {
        guard !store.state.searchMessage.isEmpty else { return }
        AmplitudeService.shared.trackEvent(tag: .click(.searchComplete))
        store.send(.searchButtonTapped)
    }

    func setButtonText(input: [String]) -> String {
        guard let first = input.first else { return "" }
        if input.count > 1 {
            return first + ", ..."
        } else {
            return first
        }
    }
}

#Preview {
    SearchView(store: SearchStore())
}
