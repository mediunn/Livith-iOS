//
//  HomeView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct HomeView: View {
    @StateObject private var store: HomeStore = .init()

    @Binding private var isTabBarHidden: Bool
    private let nickname: Binding<String>
    private let showToast: ((LivithToastType, String) -> Void)?

    init(nickname: Binding<String>, isTabBarHidden: Binding<Bool>, showToast: ((LivithToastType, String) -> Void)? = nil) {
        self.nickname = nickname
        self._isTabBarHidden = isTabBarHidden
        self.showToast = showToast
    }
    
    var body: some View {
        content()
            .background(.livithColor(.black90))
            .onAppear {
                store.send(.onAppear)
            }
            .onChange(of: store.state.errorMessage) { _, newValue in
                if !newValue.isEmpty {
                    showToast?(.failure, newValue)
                    store.send(.onErrorToastDisappear)
                }
            }
            .onChange(of: store.state.toastMessage) { _, newValue in
                if !newValue.isEmpty {
                    showToast?(.deletionSuccess, newValue)
                    store.send(.onToastDisappear)
                }
            }
    }

    @ViewBuilder
    private func content() -> some View {
        if store.state.interestConcert != nil {
            HomeInterestConcertView(
                store: store,
                isTabBarHidden: $isTabBarHidden
            )
        } else {
            HomeConcertSectionView(nickname: nickname, store: store)
        }
    }
}
