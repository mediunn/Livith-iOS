//
//  HomeScope.swift
//  HomeFeature
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct HomeScope<State, Intent> {
    let state: State
    let send: (Intent) -> DiscardableTask
}
