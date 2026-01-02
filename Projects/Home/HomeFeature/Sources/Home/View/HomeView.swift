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

    init(nickname: Binding<String>, isTabBarHidden: Binding<Bool>) {
        self.nickname = nickname
        self._isTabBarHidden = isTabBarHidden
    }
    
    var body: some View {
        content()
            .livithToast(
                isPresented: Binding(
                    get: { !store.state.errorMessage.isEmpty },
                    set: { _ in store.send(.onErrorToastDisappear) }
                ),
                type: .failure,
                message: store.state.errorMessage,
                duration: 2,
                position: .safeAreaTop
            )
            .livithToast(
                isPresented: Binding(
                    get: { !store.state.toastMessage.isEmpty },
                    set: { _ in store.send(.onToastDisappear) }
                ),
                type: .success,
                message: store.state.toastMessage,
                duration: 2,
                position: .safeAreaTop
            )
            .background(.livithColor(.black90))
            .onAppear {
                store.send(.onAppear)
            }
    }

    @ViewBuilder
    private func content() -> some View {
        switch store.state.mode {
        case .noInterestedConcert:
            HomeNoInterestView(nickname: nickname)
        case .hasInterestedConcert(let concert):
            HomeInterestConcertView(
                store: HomeInterestConcertStore(interestConcert: concert, onDeleteConcert: { [weak store] in
                    store?.send(.onDeleteInterestConcert)
                }),
                isTabBarHidden: $isTabBarHidden
            )
        }
    }
}
