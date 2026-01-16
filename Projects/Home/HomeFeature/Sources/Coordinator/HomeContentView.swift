//
//  HomeContentView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import UIKit

import LivithDesignSystem

public struct HomeContentView: View {
    @State private var coordinator: HomeCoordinator
    @Binding private var isTabBarHidden: Bool
    @Binding private var deepLinkConcertID: Int?

    public init(
        nickname: Binding<String>,
        isTabBarHidden: Binding<Bool>,
        deepLinkConcertID: Binding<Int?> = .constant(nil),
        showToast: ((LivithToastType, String) -> Void)? = nil
    ) {
        self._coordinator = State(initialValue: HomeCoordinator(nickname: nickname, isTabBarHidden: isTabBarHidden, showToast: showToast))
        self._isTabBarHidden = isTabBarHidden
        self._deepLinkConcertID = deepLinkConcertID
    }

    public var body: some View {
        HomeNavigationHost(coordinator: coordinator, isTabBarHidden: $isTabBarHidden)
            .ignoresSafeArea()
            .onChange(of: deepLinkConcertID) { _, newValue in
                if let concertID = newValue {
                    coordinator.popToRoot()
                    coordinator.showConcertDetail(concertID: concertID)
                    deepLinkConcertID = nil
                }
            }
    }
}

// MARK: - NavigationHost

private extension HomeContentView {
    struct HomeNavigationHost: UIViewControllerRepresentable {
        let coordinator: HomeCoordinator
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
