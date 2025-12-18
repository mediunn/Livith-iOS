//
//  ExploreRootView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Router
public struct ExploreRootView: View {
    @StateObject private var router: ExploreRouter = ExploreRouter()
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            router.view(to: .explore, with: .push)
                .navigationDestination(for: ExploreRoute.self) { route in
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
    }
}
