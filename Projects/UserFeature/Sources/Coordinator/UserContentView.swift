//
//  UserContentView.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/28/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import UIKit

import LivithDesignSystem

public struct UserContentView: View {
    @State private var coordinator: UserCoordinator
    @Binding private var isTabBarHidden: Bool
    private let onNavigateToHome: (() -> Void)?

    public init(
        isTabBarHidden: Binding<Bool>,
        onNavigateToHome: (() -> Void)? = nil
    ) {
        self._coordinator = State(initialValue: UserCoordinator(isTabBarHidden: isTabBarHidden, onNavigateToHome: onNavigateToHome))
        self._isTabBarHidden = isTabBarHidden
        self.onNavigateToHome = onNavigateToHome
    }

    public var body: some View {
        UserNavigationHost(coordinator: coordinator, isTabBarHidden: $isTabBarHidden)
            .ignoresSafeArea()
    }
}

// MARK: - NavigationHost

private extension UserContentView {
    struct UserNavigationHost: UIViewControllerRepresentable {
        let coordinator: UserCoordinator
        @Binding var isTabBarHidden: Bool

        func makeCoordinator() -> NavDelegate {
            NavDelegate(isTabBarHidden: $isTabBarHidden)
        }

        final class NavDelegate: NSObject, UINavigationControllerDelegate {
            @Binding var isTabBarHidden: Bool

            init(isTabBarHidden: Binding<Bool>) {
                self._isTabBarHidden = isTabBarHidden
            }

            func navigationController(
                _ navigationController: UINavigationController,
                willShow viewController: UIViewController,
                animated: Bool
            ) {
                let stackCount = navigationController.viewControllers.count
                Task { @MainActor in
                    isTabBarHidden = stackCount > 1
                }
            }
        }

        func makeUIViewController(context: Context) -> UINavigationController {
            let nav = coordinator.navigationController
            nav.delegate = context.coordinator
            if nav.viewControllers.isEmpty {
                coordinator.start()
            }
            return nav
        }

        func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    }
}
