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

    private let nickname: Binding<String>

    init(nickname: Binding<String>) {
        self.nickname = nickname
    }
    
    var body: some View {
        Group {
            switch store.state.mode {
            case .noInterestedConcert:
                HomeNoInterestView(nickname: nickname)
            case .hasInterestedConcert(let concert):
                EmptyView()
            }
        }
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
        .background(.livithColor(.black90))
        .onAppear {
            store.send(.onAppear)
        }
    }
}
