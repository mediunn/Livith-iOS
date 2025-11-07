//
//  SearchView.swift
//  Search
//
//  Created by Youjin Lee on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import SearchDomain
import DesignSystem

public struct SearchView: View {
    
    // MARK: - Property

    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    
    @State private var searchedConcerts: [SearchDomain.ConcertEntity] = []
    @State private var selectedGenreList: [SearchDomain.ConcertGenre] = []
    @State private var selectedStatusList: [SearchDomain.ConcertStatus] = []
    
    @State private var selectedSort: SearchDomain.SearchSort = .latest

    @State private var errorMessage: String = ""
    
    @State private var showFilter: Bool = false
    @State private var showSort: Bool = false

    // MARK: - Lifecycle
    
    public init() { }
    
    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            searchBarView
                .padding(.bottom, 16)
            
            filterView
                .padding(.bottom, 16)
            
            if searchedConcerts.isEmpty {
                searchEmptyView
                    .padding(.top, 183)
            } else {
                ScrollView {
                    searchGrid
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(Color.livithColor(.black100))
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $showFilter) {
            filterBottomSheet
        }
    }
}

// MARK: - UIComponents

private extension SearchView {
    var genreFilterType: FilterButtonType {
        if selectedGenreList.isEmpty {
            return .normal
        } else {
            let genreNames = selectedGenreList.map { $0.genreText }
            let text: String
            if genreNames.count > 1 {
                text = genreNames[0] + ", ..."
            } else {
                text = genreNames[0]
            }
            return .selected(text: text)
        }
    }

    var statusFilterType: FilterButtonType {
        if selectedStatusList.isEmpty {
            return .normal
        } else {
            let statusNames = selectedStatusList.map { $0.filterText }
            let text: String
            if statusNames.count > 1 {
                text = statusNames[0] + ", ..."
            } else {
                text = statusNames[0]
            }
            return .selected(text: text)
        }
    }

    var searchBarView: some View {
        SearchBarView(input: $searchText, onSubmit: performSearch)
            .foregroundStyle(Color.livithColor(.black100))
    }

    var filterView: some View {
        HStack(alignment: .center, spacing: 0) {
            FilterButton(
                style: .genre,
                type: genreFilterType,
                action: { showFilter = true },
                onClear: { selectedGenreList = [] }
            )
            .padding(.leading, 16)

            FilterButton(
                style: .status,
                type: statusFilterType,
                action: { showFilter = true },
                onClear: { selectedStatusList = [] }
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
                Text(selectedSort == .latest ? "최신순" : "가나다순")
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
            }
        }
    }
    
    var sortView: some View {
        VStack(alignment: .center, spacing: 0) {
            SortOptionButton(
                title: "최신순",
                isSelected: selectedSort == .latest,
                action: {
                    selectedSort = .latest
                    showSort = false
                }
            )
            .padding(.bottom, 8)

            SortOptionButton(
                title: "가나다순",
                isSelected: selectedSort == .alphabetical,
                action: {
                    selectedSort = .alphabetical
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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
            ForEach(searchedConcerts, id: \.id) { concert in
                ConcertDetailCard(
                    posterURL: concert.posterURL,
                    title: concert.title,
                    date: concert.startDate,
                    artist: concert.artist,
                    status: concert.status.statusChipText,
                    remainDays: concert.daysLeft
                )
            }
        }
    }
    
    var filterBottomSheet: some View {
        FilterBottomSheetView(
            selectedGenreList: $selectedGenreList,
            selectedStatusList: $selectedStatusList,
            showFilter: $showFilter
        )
    }
}

// MARK: - Helper Method

private extension SearchView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func performSearch() {
        guard !searchText.isEmpty else { return }
        // TODO: 실제 검색 로직 구현
        isSearchActive = true
        hideKeyboard()
    }
}

#Preview {
    SearchView()
}
