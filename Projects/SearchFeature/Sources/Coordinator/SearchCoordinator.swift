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

import LivithDesignSystem
import Coordinator

final class SearchCoordinator: Coordinator {
    typealias R = SearchRoute

    let navigationController: UINavigationController

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

    // MARK: - Concert (임시 어댑터, Plan 3에서 정식 Router로 대체)

    func showConcertDetail(concertID: Int) {
        let view = ConcertCoordinatorView(
            concertID: concertID,
            initialTab: .artistDetail,
            initialSection: nil
        )
        let hosting = UIHostingController(rootView: view)
        hosting.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(hosting, animated: true)
    }
}
