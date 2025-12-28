//
//  HomeCoordinator.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

final class HomeCoordinator: Coordinator {
    typealias R = HomeRoute
    
    let navigationController: UINavigationController
    
    private let nickname: Binding<String>
    
    init(nickname: Binding<String>) {
        self.navigationController = UINavigationController()
        self.nickname = nickname
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        push(to: .home, animated: false)
    }
    
    func buildViewController(for route: R) -> UIViewController {
        switch route {
        case .home:
            return UIHostingController(rootView: HomeView(nickname: nickname).environment(\.homeCoordinator, self))

        case .interest:
            return UIHostingController(rootView: InterestTempView().environment(\.homeCoordinator, self))
        }
    }
}
