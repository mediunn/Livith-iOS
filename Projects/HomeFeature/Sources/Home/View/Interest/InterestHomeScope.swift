//
//  InterestHomeScope.swift
//  HomeFeature
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct InterestHomeScope {
    let state: InterestHomeState
    let send: (InterestHomeIntent) -> DiscardableTask
}
