//
//  InterestConcertTab.swift
//  HomeFeature
//
//  Created by 김진웅 on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

enum InterestConcertTab: Int, CaseIterable {
    case schedule = 0
    case setlist = 1

    var title: String {
        switch self {
        case .schedule:
            return "콘서트 일정"
        case .setlist:
            return "셋리스트"
        }
    }
}
