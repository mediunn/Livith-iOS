//
//  AppRootView.swift
//  Livith-iOS
//
//  Created by 김진웅 on 12/13/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LoginFeature
import LivithNetwork

struct AppRootView: View {
    @State private var currentRoute: AppRoute?
    
    private let tokenService: TokenService
    private let initialCheckID: UUID = UUID()
    
    init(tokenService: TokenService = TokenServiceImpl()) {
        self.tokenService = tokenService
    }
    
    var body: some View {
        Group {
            if let route = currentRoute {
                switch route {
                case .login:
                    LoginRootView {
                        currentRoute = .main
                    }
                case .main:
                    LivithMainTabView()
                }
            } else {
                Color.clear
            }
        }
        .animation(.easeInOut(duration: 0.5), value: currentRoute)
        .task(id: initialCheckID) {
            await checkInitialRoute()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.reloginRequired)) { _ in
            currentRoute = .login
        }
    }
}

// MARK: - Helpers

private extension AppRootView {
    func checkInitialRoute() async {
        do {
            try await tokenService.refresh()
            currentRoute = .main
        } catch {
            print(">>> [\(#line): \(#function)] - \(error)")
            currentRoute = .login
        }
    }
}
