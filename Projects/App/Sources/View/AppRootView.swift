//
//  AppRootView.swift
//  Livith-iOS
//
//  Created by 김진웅 on 12/13/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LoginFeature

struct AppRootView: View {
    @State private var currentRoute: AppRoute = .login
    
    var body: some View {
        Group {
            switch currentRoute {
            case .login:
                LoginRootView {
                    currentRoute = .main
                }
            case .main:
                LivithMainTabView()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.7), value: currentRoute)
    }
}
