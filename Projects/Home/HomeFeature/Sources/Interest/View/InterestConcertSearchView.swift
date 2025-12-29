//
//  InterestTempView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

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
                
                Spacer()
            }
        }
        .background(.livithColor(.black100))
        .ignoresSafeArea(edges: .bottom)
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
                
                if !store.state.searchText.isEmpty, isTextFieldFocused { deleteButton }
                
                if store.state.searchText.isEmpty { searchButton }
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
}

// MARK: - Helpers

private extension InterestConcertSearchView {
    var searchText: Binding<String> {
        Binding(
            get: { store.state.searchText },
            set: { store.send(.updateText($0)) }
        )
    }
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
