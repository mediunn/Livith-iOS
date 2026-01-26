//
//  LoginContentView.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import UIKit

public struct LoginContentView: View {
    @State private var coordinator: LoginCoordinator
    
    public init(
        onLoginCompleted: @escaping () -> Void,
        onSignupCompleted: @escaping (String) -> Void
    ) {
        _coordinator = State(
            initialValue: LoginCoordinator(
                onLoginCompleted: onLoginCompleted,
                onSignupCompleted: onSignupCompleted
            )
        )
    }
    
    public var body: some View {
        LoginNavigationHost(coordinator: coordinator)
            .ignoresSafeArea()
    }
}

// MARK: - NavigationHost

private extension LoginContentView {
    struct LoginNavigationHost: UIViewControllerRepresentable {
        let coordinator: LoginCoordinator
        
        func makeUIViewController(context: Context) -> UINavigationController {
            let nav = coordinator.navigationController
            if nav.viewControllers.isEmpty {
                coordinator.start()
            }
            return nav
        }
        
        func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    }
}
