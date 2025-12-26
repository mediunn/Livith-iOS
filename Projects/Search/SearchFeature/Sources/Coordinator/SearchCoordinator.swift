//
//  SearchCoordinator.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import UIKit

import DSKit

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
}
