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
    @FocusState private var isTextFieldFocused: Bool
    
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
                
                scrollView
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                
                submitButton
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
            }
        }
    }
}

// MARK: - UIComponents

private extension InterestConcertSearchView {
    var navigationBar: some View {
        HStack(spacing: 0) {
            Button {
                coordinator?.pop()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 36, height: 36)
            }
            .padding(.leading, 16)
            
            Text("공연 설정하기")
                .notosans(.body1Semibold)
                .foregroundStyle(.livithColor(.white100))
                .padding(.bottom, 2)
            
            Spacer()
        }
    }
    
    var searchTextField: some View {
        ZStack(alignment: .leading) {
            if !isTextFieldFocused, store.state.searchText.isEmpty { placeholder }
            
            HStack {
                TextField("", text: searchText)
                    .notosans(.body3Medium)
                    .foregroundStyle(.livithColor(.white100))
                    .autocorrectionDisabled()
                    .focused($isTextFieldFocused)
                    .onSubmit { isTextFieldFocused = false }
                
                if isWriting {
                    deleteButton
                } else {
                    searchButton
                }
            }
            .frame(height: Constants.textFieldHeight)
            .padding(.horizontal, 12)
            .background(.livithColor(.black90))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.livithColor(.black50), lineWidth: isTextFieldFocused ? 1 : 0)
            )
        }
        .onTapGesture { isTextFieldFocused = true }
    }
    
    var placeholder: some View {
        Text(Literals.placeholder)
            .notosans(.body3Medium)
            .foregroundStyle(.livithColor(.black50))
            .padding(.leading, 12)
            .zIndex(2)
    }
    
    var deleteButton: some View {
        Button {
            store.send(.updateText(""))
        } label: {
            Image.livithIcon(.deleteFillDefault)
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
        }
    }
    
    var searchButton: some View {
        Button {
            store.send(.onSearch)
        } label: {
            Image.livithIcon(.searchLineDefault)
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
        }
    }
    
    var scrollView: some View {
        ScrollView(showsIndicators: false) {
            if isTextFieldFocused { // 1순위: 입력 중
                recommendKeywordListView
            } else if !store.state.searchList.isEmpty, !store.state.searchText.isEmpty, !isTextFieldFocused { // 2순위: 검색 완료
                searchResultGridView
            } else if store.state.searchText.isEmpty { // 3순위: 초기 상태
                concertGridView
            }
        }
        .onTapGesture { isTextFieldFocused = false }
    }

    var concertGridView: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
            spacing: 16
        ) {
            ForEach(store.state.concertList, id: \.id) { concert in
                ConcertDetailCard(
                    posterURL: concert.posterURL,
                    title: concert.title,
                    date: concert.startDate,
                    artist: concert.artist,
                    status: concert.status.statusChipText,
                    remainDays: concert.daysLeft,
                    isSelected: store.state.selectedConcertID == concert.id
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .onTapGesture {
                    print("Tapped concert id: \(concert.id)")
                    store.send(.selectConcert(concert.id))
                }
            }
        }
    }
    
    var recommendKeywordListView: some View {
        HStack {
            RecommendKeywordListView(
                searchText: store.state.searchText,
                keywordList: store.state.recommendKeywordList,
                onTap: { keyword in
                    store.send(.updateText(keyword))
                    store.send(.onSearch)
                    isTextFieldFocused = false
                }
            )
            
            Spacer()
        }
    }
    
    var searchResultGridView: some View {
        VStack(alignment: .leading, spacing: 20) {
            searchResultText
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
                spacing: 16
            ) {
                searchResultRow
            }
        }
    }

    var searchResultText: some View {
        (Text("검색 결과 ")
            .foregroundStyle(.livithColor(.black5)) +
         Text("\(store.state.searchList.count)개")
            .foregroundStyle(.livithColor(.yellow30)) +
         Text("의 정보가 있어요")
            .foregroundStyle(.livithColor(.black5)))
            .notosans(.body2Medium)
    }
    
    var searchResultRow: some View {
        ForEach(store.state.searchList, id: \.id) { concert in
            ConcertDetailCard(
                posterURL: concert.posterURL,
                title: concert.title,
                date: concert.startDate,
                artist: concert.artist,
                status: concert.status.statusChipText,
                remainDays: concert.daysLeft,
                isSelected: store.state.selectedConcertID == concert.id
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .onTapGesture {
                print("Tapped concert id: \(concert.id)")
                store.send(.selectConcert(concert.id))
            }
        }
    }

    var submitButton: some View {
        Button {

        } label: {
            Text("설정하기")
                .notosans(.body3Medium)
                .foregroundColor(store.state.selectedConcertID != nil ? Color.livithColor(.black100) : Color.livithColor(.black50))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(store.state.selectedConcertID != nil ? Color.livithColor(.yellow30) : Color.livithColor(.black80))
                .cornerRadius(8)
        }
        .disabled(store.state.selectedConcertID == nil)
    }
}

// MARK: - Helpers

private extension InterestConcertSearchView {
    var searchText: Binding<String> {
        Binding(
            get: { store.state.searchText },
            set: { store.send(.updateText($0)) }
        )
    }
    
    var isWriting: Bool { isTextFieldFocused && !store.state.searchText.isEmpty }
}

// MARK: - Literals & Constants

private extension InterestConcertSearchView {
    enum Literals {
        static let placeholder = "찾고 있는 콘서트나 가수를 검색하세요"
    }
    
    enum Constants {
        static let iconSize: CGFloat = 36
        static let textFieldHeight: CGFloat = 52
    }
}

#Preview {
    let nickname = Binding.constant("유지미")
    let coordinator = HomeCoordinator(nickname: nickname)
    InterestConcertSearchView()
        .environment(\.homeCoordinator, coordinator)
}
