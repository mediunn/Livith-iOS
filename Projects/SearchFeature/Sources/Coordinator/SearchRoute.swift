//
//  SearchRoute.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

enum SearchRoute: Hashable {
    case explore
    case search
    case concertDetail(concertID: Int)
}
