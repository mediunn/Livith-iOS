//
//  HomeRouter.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/24/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import Observation

import Router

@Observable
final class HomeRouter: Router {
    typealias R = HomeRoute
    
    var path: NavigationPath = .init()
    var sheet: HomeRoute?
    var fullScreenCover: HomeRoute?
    
    private let nickname: Binding<String>
    
    init(nickname: Binding<String>) {
        self.nickname = nickname
    }
    
    func view(to route: HomeRoute, with style: PresentationStyle) -> AnyView {
        switch route {
        case .home:
            AnyView(HomeView(nickname: nickname))
        }
    }
}
