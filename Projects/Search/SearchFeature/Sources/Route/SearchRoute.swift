//
//  SearchRoute.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Router

enum SearchRoute: Route {
    case explore
    case search

    var id: String {
        switch self {
        case .explore:
            return "explore"
        case .search:
            return "search"
        }
    }
}
