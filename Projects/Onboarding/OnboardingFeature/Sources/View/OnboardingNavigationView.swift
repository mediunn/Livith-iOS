//
//  OnboardingNavigationView.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Routing

public struct OnboardingNavigationView: View {
    @StateObject private var router = OnboardingRouter()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            router.view(to: .terms, with: .push)
                .navigationDestination(for: OnboardingRoute.self) { route in
                    router.view(to: route, with: .push)
                        .navigationBarHidden(true)
                }
        }
        .fullScreenCover(item: $router.fullScreenCover) { route in
            router.view(to: route, with: .fullScreen)
        }
        .environmentObject(router)
    }
}

#Preview {
    OnboardingNavigationView()
}
