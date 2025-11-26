//
//  SearchView.swift
//  Search
//
//  Created by Youjin Lee on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Combine
import SwiftUI

import DesignSystem
import SearchDomain

public struct SearchView: View {

    // MARK: - Property

    @ObservedObject private var store: SearchStore

    @State private var showError: Bool = false
    @State private var showFilter: Bool = false
    @State private var showSort: Bool = false

    // MARK: - Initializer

    public init(store: SearchStore) {
        self.store = store
        
        store.send(.viewDidLoad)
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            searchBarView
                .padding(.bottom, 16)

            filterView
                .padding(.bottom, 16)
                .zIndex(100)
            
            if store.state.searchedConcertList.isEmpty {
                searchEmptyView
                    .padding(.top, 183)
            } else {
                ScrollView {
                    searchGrid
                        .padding(.horizontal, 16)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: store.state.searchedConcertList.map { $0.id })
        .background(Color.livithColor(.black100))
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: store.state.errorMessage) { _, newValue in
            showError = !newValue.isEmpty
        }
        .overlay {
            if showError {
                ErrorSheetView(
                    title: "오류가 발생했어요!",
                    message: store.state.errorMessage
                )
            }
        }
        .overlay {
            customFilterSheet
                .ignoresSafeArea()
        }
    }
}

// MARK: - UIComponents

private extension SearchView {
    var genreFilterType: FilterButtonType {
        if store.state.selectedGenreList.isEmpty {
            return .normal
        } else {
            let genreNames = store.state.selectedGenreList.map { $0.genreText }
            
            return .selected(text: setButtonText(input: genreNames))
        }
    }

    var statusFilterType: FilterButtonType {
        if store.state.selectedStatusList.isEmpty {
            return .normal
        } else {
            let statusNames = store.state.selectedStatusList.map { $0.filterText }
            
            return .selected(text: setButtonText(input: statusNames))
        }
    }

    var searchBarView: some View {
        SearchBarView(
            input: Binding(
                get: { store.state.searchMessage },
                set: { store.send(.updateSearchMessage($0)) }
            ),
            onChange: {
                if isCompleteKorean() { performSearch() }
            },
            onSubmit:  {
                performSearch()
                hideKeyboard()
            }
        )
        .foregroundStyle(Color.livithColor(.black100))
    }

    var filterView: some View {
        HStack(alignment: .center, spacing: 0) {
            FilterButton(
                style: .genre,
                type: genreFilterType,
                action: { showFilter = true },
                onClear: {
                    store.send(.settingButtonTapped(genres: [], status: store.state.selectedStatusList))
                }
            )
            .padding(.leading, 16)

            FilterButton(
                style: .status,
                type: statusFilterType,
                action: { showFilter = true },
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
            SortOptionButton(
                title: "최신순",
                isSelected: store.state.sortState == .latest,
                action: {
                    store.send(.sortStateChanged(.latest))
                    showSort = false
                }
            )
            .padding(.bottom, 8)

            SortOptionButton(
                title: "가나다순",
                isSelected: store.state.sortState == .alphabetical,
                action: {
                    store.send(.sortStateChanged(.alphabetical))
                    showSort = false
                }
            )
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
        EmptyView(text: "검색 결과가 없어요")

        Spacer()
    }
    
    var searchGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
            spacing: 16
        ) {
            ForEach(store.state.searchedConcertList, id: \.id) { concert in
                ConcertDetailCard(
                    posterURL: concert.posterURL,
                    title: concert.title,
                    date: concert.startDate,
                    artist: concert.artist,
                    status: concert.status.statusChipText,
                    remainDays: concert.daysLeft
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
    
    var filterBottomSheet: some View {
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

    var customFilterSheet: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(showFilter ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    showFilter = false
                }
                .allowsHitTesting(showFilter)
                .animation(.easeInOut(duration: 0.3), value: showFilter)
            
            VStack(spacing: 0) {
                filterBottomSheet
            }
            .frame(maxWidth: .infinity)
            .background(Color.livithColor(.black90))
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 16
                )
            )
            .drawingGroup()
            .offset(y: showFilter ? 0 : 420)
            .animation(.easeInOut(duration: 0.3), value: showFilter)
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
        
        return !String(lastChar).contains(/[ㄱ-ㅎ]/)
    }
    
    func performSearch() {
        guard !store.state.searchMessage.isEmpty else { return }
        store.send(.searchButtonTapped)
    }
    
    func setButtonText(input: [String]) -> String {
        if input.count > 1 {
            return input[0] + ", ..."
        } else {
            return input[0]
        }
    }
}

#Preview {
    SearchView(store: SearchStore())
}
