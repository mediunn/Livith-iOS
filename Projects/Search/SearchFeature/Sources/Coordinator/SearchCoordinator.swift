//
//  SearchCoordinator.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import UIKit

import ConcertFeature

import DSKit

final class SearchCoordinator: Coordinator {
    typealias R = SearchRoute

    let navigationController: UINavigationController

    private var concertCoordinator: ConcertCoordinator?

    init() {
        self.navigationController = UINavigationController()

        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        push(to: .explore, animated: false)
    }

    func buildViewController(for route: SearchRoute) -> UIViewController {
        switch route {
        case .explore:
            return UIHostingController(rootView: ExploreView().environment(\.searchCoordinator, self))
        case .search:
            return UIHostingController(rootView: SearchView(store: .init()).environment(\.searchCoordinator, self))
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
