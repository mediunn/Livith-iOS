//
//  SearchRootView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Router

public struct SearchRootView: View {
    @StateObject private var router: SearchRouter = SearchRouter()

    @Binding private var isTabBarHidden: Bool

    public init(isTabBarHidden: Binding<Bool>) {
        self._isTabBarHidden = isTabBarHidden
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            router.view(to: .explore, with: .push)
                .navigationDestination(for: SearchRoute.self) { route in
                    router.view(to: route, with: .push)
                        .navigationBarHidden(true)
                }
        }
        .sheet(item: $router.sheet) { route in
            router.view(to: route, with: .sheet)
        }
        .fullScreenCover(item: $router.fullScreenCover) { route in
            router.view(to: route, with: .fullScreen)
        }
        .environmentObject(router)
        .onChange(of: router.path) { oldValue, newValue in
            isTabBarHidden = !newValue.isEmpty
        }
    }
}
