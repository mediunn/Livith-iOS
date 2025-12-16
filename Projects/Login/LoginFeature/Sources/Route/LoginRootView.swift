//
//  LoginRootView.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation
import SwiftUI

import Routing

public struct LoginRootView: View {
    @StateObject private var router = LoginRouter()
    
    private let onAuthenticationComplete: () -> Void
    
    public init(onAuthenticationComplete: @escaping () -> Void = {}) {
        self.onAuthenticationComplete = onAuthenticationComplete
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            router.view(to: .login, with: .push)
                .navigationDestination(for: LoginRoute.self) { route in
                    router.view(to: route, with: .push)
                        .navigationBarHidden(true)
                }
        }
        .fullScreenCover(item: $router.fullScreenCover) { route in
            router.view(to: route, with: .fullScreen)
        }
        .environmentObject(router)
        .onChange(of: router.authenticationCompleted) { completed in
            if completed {
                onAuthenticationComplete()
            }
        }
    }
}
