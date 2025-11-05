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
    var searchBarView: some View {
        SearchBarView(input: $searchText)
            .foregroundStyle(Color.livithColor(.black100))
    }
    
    var filterView: some View {
        HStack(alignment: .center, spacing: 0) {
            FilterButton(style: .genre, type: .normal, action: {
                showFilter = true
            })
                .padding(.leading, 16)

            FilterButton(style: .status, type: .normal, action: {
                showFilter = true
            })
                .padding(.leading, 8)

            Spacer()
        }
    }
    
    @ViewBuilder
    var searchEmptyView: some View {
        EmptyView(text: "검색 결과가 없어요")

        Spacer()
    }
    
    var searchGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(searchedConcerts, id: \.id) { concert in
                ConcertDetailCard(
                    posterURL: concert.posterURL,
                    title: concert.title,
                    date: concert.startDate,
                    artist: concert.artist,
                    status: concert.status.statusText,
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
}

#Preview {
    SearchView()
}
