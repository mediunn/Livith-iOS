//
//  SearchRouter.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Router

@MainActor
final class SearchRouter: Router {
    typealias R = SearchRoute
    
    @Published var path = NavigationPath()
    @Published var sheet: R?
    @Published var fullScreenCover: R?
    
    func view(to route: SearchRoute, with style: PresentationStyle) -> AnyView {
        switch route {
        case .explore:
            return AnyView(
                ExploreView()
            )
        case .search:
            return AnyView(
                SearchView(store: .init())
            )
        }
    }
}
