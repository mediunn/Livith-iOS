//
//  SearchCoordinatorView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertFeature
import Coordinator

// MARK: - SearchRouter

typealias SearchRouter = Router<SearchRoute>

// MARK: - SearchCoordinatorView

public struct SearchCoordinatorView: View {

    // MARK: - Property

    @StateObject private var router: SearchRouter

    // MARK: - Initializer

    public init() {
        _router = StateObject(wrappedValue: SearchRouter())
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(path: $router.path) {
            ExploreView()
                .navigationDestination(for: SearchRoute.self) { route in
                    destinationView(for: route)
                        .toolbar(.hidden, for: .tabBar, .navigationBar)
                }
        }
        .environmentObject(router)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func destinationView(for route: SearchRoute) -> some View {
        switch route {
        case .explore:
            ExploreView()
        case .search:
            SearchView(store: .init())
        case .concertDetail(let concertID):
            ConcertCoordinatorView(
                concertID: concertID,
                initialTab: .artistDetail,
                initialSection: nil
            )
        }
    }
}
