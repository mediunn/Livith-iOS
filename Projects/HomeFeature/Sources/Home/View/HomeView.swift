//
//  HomeView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct HomeView: View {
    @StateObject private var store: HomeStore = .init()
    
    @Binding private var isTabBarHidden: Bool
    
    @State private var showErrorToast = false
    @State private var showSuccessToast = false
    
    init(isTabBarHidden: Binding<Bool>) {
        self._isTabBarHidden = isTabBarHidden
    }
    
    var body: some View {
        content()
            .background(.livithColor(.black90))
            .onAppear {
                store.send(.onAppear)
            }
            .onChange(of: store.state.errorMessage) { _, newValue in
                if !newValue.isEmpty {
                    showErrorToast = true
                }
            }
            .onChange(of: store.state.toastMessage) { _, newValue in
                if !newValue.isEmpty {
                    showSuccessToast = true
                }
            }
            .livithToast(
                isPresented: Binding(
                    get: { showErrorToast && !store.state.errorMessage.isEmpty },
                    set: { if !$0 { showErrorToast = false; store.send(.onErrorToastDisappear) } }
                ),
                type: .failure,
                message: store.state.errorMessage
            )
            .livithToast(
                isPresented: Binding(
                    get: { showSuccessToast && !store.state.toastMessage.isEmpty },
                    set: { if !$0 { showSuccessToast = false; store.send(.onToastDisappear) } }
                ),
                type: .success,
                message: store.state.toastMessage
            )
    }
    
    @ViewBuilder
    private func content() -> some View {
        if store.state.user?.interestConcertID != nil {
            HomeInterestConcertView(
                store: store,
                isTabBarHidden: $isTabBarHidden
            )
        } else {
            HomeConcertSectionView(store: store)
        }
    }
}
