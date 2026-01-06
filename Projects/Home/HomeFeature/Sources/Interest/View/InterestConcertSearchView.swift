//
//  InterestTempView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeDomain

struct InterestConcertSearchView: View {
    @Environment(\.homeCoordinator) private var coordinator
    @StateObject private var store = InterestConcertSearchStore()
    @State private var isTextFieldFocused: Bool = false
    
    var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .ignoresSafeArea()
                .onTapGesture { isTextFieldFocused = false }
            
            VStack(spacing: .zero) {
                navigationBar
                    .padding(.top, 20)
                
                searchTextField
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                
                Spacer()
                
                scrollView
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                
                submitButton
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
            }
            .ignoresSafeArea(.keyboard)
            .livithToast(
                isPresented: Binding(
                    get: { !store.state.errorMessage.isEmpty },
                    set: { _ in store.send(.onToastDisappear) }
                ),
                type: .failure,
                message: store.state.errorMessage,
                duration: 2,
                position: .safeAreaTop
            )
            .onChange(of: isTextFieldFocused) { _, isFocused in
                if isFocused {
                    store.send(.onModeChange(.recommendingKeywords))
                } else if store.state.mode == .recommendingKeywords {
                    if store.state.searchText.isEmpty {
                        store.send(.onModeChange(.initial))
                    }
                }
            }
            .onChange(of: store.state.completedConcert) { _, concert in
                guard let concert = concert else { return }
                coordinator?.push(to: .interestComplete(posterURL: concert.posterURL, title: concert.title))
            }
        }
    }
}

// MARK: - UIComponents

private extension InterestConcertSearchView {
    var navigationBar: some View {
        LivithNavigationView(
            type: .back(title: "공연 설정하기", onBack: { coordinator?.pop() })
        )
    }
    
    var searchTextField: some View {
        LivithTextField(
            text: searchText,
            isFocused: $isTextFieldFocused,
            type: .search,
            placeholder: Literals.placeholder,
            onSubmit: { store.send(.onSearch) },
            onClear: { store.send(.onTextChange("")) }
        )
    }
    
    var scrollView: some View {
        Group {
            switch store.state.mode {
            case .initial:
                ConcertGridView(
                    concerts: store.state.concertList,
                    selectedID: store.state.selectedConcertID,
                    isLoadingMore: store.state.isConcertsLoadingMore,
                    onConcertTap: { store.send(.onConcertTap($0)) },
                    onLoadMore: { store.send(.onLoadMoreConcerts) }
                )
            case .recommendingKeywords:
                RecommendKeywordListView(
                    searchText: store.state.searchText,
                    keywordList: store.state.recommendKeywordList,
                    onTap: { keyword in
                        store.send(.onTextChange(keyword))
                        isTextFieldFocused = false
                        store.send(.onSearch)
                    }
                )
            case .showingSearchResults:
                SearchResultGridView(
                    searchResults: store.state.searchList,
                    selectedID: store.state.selectedConcertID,
                    isLoadingMore: store.state.isSearchResultsLoadingMore,
                    onConcertTap: { store.send(.onConcertTap($0)) },
                    onLoadMore: { store.send(.onLoadMoreSearchResults) }
                )
            }
        }
        .onTapGesture { isTextFieldFocused = false }
    }
    
    var submitButton: some View {
        LivithButton("설정하기", variant: .primary) {
            store.send(.onSubmit)
        }
        .disabled(store.state.selectedConcertID == nil)
    }
}

// MARK: - Helpers

private extension InterestConcertSearchView {
    var searchText: Binding<String> {
        Binding(
            get: { store.state.searchText },
            set: { store.send(.onTextChange($0)) }
        )
    }
}

// MARK: - Literals

private extension InterestConcertSearchView {
    enum Literals {
        static let placeholder = "찾고 있는 콘서트나 가수를 검색하세요"
    }
}
