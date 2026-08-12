//
//  InterestHomeScope.swift
//  HomeFeature
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

struct InterestHomeScope {
    let state: InterestHomeState
    let user: User?
    let send: (InterestHomeIntent) -> DiscardableTask
}
