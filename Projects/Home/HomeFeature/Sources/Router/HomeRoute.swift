//
//  HomeRoute.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/24/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Router

enum HomeRoute: Route {
    case home

    var id: String {
        switch self {
        case .home:
            return "home"
        }
    }
}
