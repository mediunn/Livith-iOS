//
//  HomeRoute.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DSKit

enum HomeRoute: Route {
    case home
    case interest
    case interestComplete(posterURL: URL?, title: String)
    case concertDetail(concertID: Int)
}
