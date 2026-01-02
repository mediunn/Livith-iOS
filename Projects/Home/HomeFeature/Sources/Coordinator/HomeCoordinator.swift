//
//  HomeCoordinator.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertFeature

import DSKit

final class HomeCoordinator: Coordinator {
    typealias R = HomeRoute

    let navigationController: UINavigationController

    private let nickname: Binding<String>
    private var concertCoordinator: ConcertCoordinator?
    private let isTabBarHidden: Binding<Bool>

    init(nickname: Binding<String>, isTabBarHidden: Binding<Bool>) {
        self.navigationController = UINavigationController()
        self.nickname = nickname
        self.isTabBarHidden = isTabBarHidden

        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        push(to: .home, animated: false)
    }

    func buildViewController(for route: R) -> UIViewController {
        switch route {
        case .home:
            return UIHostingController(rootView: HomeView(nickname: nickname, isTabBarHidden: isTabBarHidden).environment(\.homeCoordinator, self))

        case .interest:
            return UIHostingController(rootView: InterestConcertSearchView().environment(\.homeCoordinator, self))

        case .interestComplete(posterURL: let url, title: let title):
            return UIHostingController(
                rootView: InteresetConcertCompleteView(concertPosterURL: url, concertTitle: title)
                    .environment(\.homeCoordinator, self)
            )
        }
    }

    func showConcertDetail(concertID: Int) {
        let coordinator = ConcertCoordinator(
            navigationController: navigationController,
            onDismiss: { [weak self] in
                self?.concertCoordinator = nil
            }
        )
        self.concertCoordinator = coordinator
        coordinator.start(concertID: concertID)
    }
}
