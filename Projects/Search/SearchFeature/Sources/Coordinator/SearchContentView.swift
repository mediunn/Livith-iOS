//
//  SearchContentView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

public struct SearchContentView: View {
    @State private var coordinator: SearchCoordinator = SearchCoordinator()
    @Binding private var isTabBarHidden: Bool

    public init(isTabBarHidden: Binding<Bool>) {
        self._isTabBarHidden = isTabBarHidden
    }

    public var body: some View {
        SearchNavigationHost(coordinator: coordinator, isTabBarHidden: $isTabBarHidden)
            .ignoresSafeArea()
    }
}

// MARK: - NavigationHost

private extension SearchContentView {
    struct SearchNavigationHost: UIViewControllerRepresentable {
        let coordinator: SearchCoordinator
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
                    self.isTabBarHidden = stackCount > 1
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
