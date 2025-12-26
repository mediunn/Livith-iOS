//
//  HomeRootView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/24/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Router

public struct HomeRootView: View {
    @State private var router: HomeRouter = .init()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            router.view(to: .home, with: .push)
                .navigationDestination(for: HomeRoute.self) { route in
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
        .environment(router)
    }
}
