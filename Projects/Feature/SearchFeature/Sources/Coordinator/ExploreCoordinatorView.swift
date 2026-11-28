//
//  ExploreCoordinatorView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertFeature
import ConcertSearch
import Routing

// MARK: - ExploreRouter

typealias ExploreRouter = Router<ExploreRoute>

// MARK: - ExploreCoordinatorView

public struct ExploreCoordinatorView: View {

    // MARK: - Property

    @Environment(SearchDependencies.self) private var searchDependencies
    @StateObject private var router: ExploreRouter

    // MARK: - Initializer

    public init() {
        _router = StateObject(wrappedValue: ExploreRouter())
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(path: $router.path) {
            ExploreHomeView()
                .navigationDestination(for: ExploreRoute.self) { route in
                    destinationView(for: route)
                        .toolbar(.hidden, for: .tabBar, .navigationBar)
                }
        }
        .environmentObject(router)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func destinationView(for route: ExploreRoute) -> some View {
        switch route {
        case .home:
            ExploreHomeView()
        case .search:
            ExploreSearchView(viewModel: .init(repository: searchDependencies.repository))
        case .concertDetail(let concertID):
            ConcertCoordinatorView(
                concertID: concertID,
                initialTab: .artistDetail,
                initialSection: nil
            )
        }
    }
}
