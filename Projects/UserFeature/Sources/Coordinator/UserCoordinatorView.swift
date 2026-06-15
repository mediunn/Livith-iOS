//
//  UserCoordinatorView.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/28/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

public struct UserCoordinatorView: View {
    @StateObject private var router: UserRouter

    public init(
        onNavigateToHome: (() -> Void)? = nil
    ) {
        _router = StateObject(
            wrappedValue: UserRouter(
                onNavigateToHome: onNavigateToHome ?? {}
            )
        )
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            UserView()
                .navigationDestination(for: UserRoute.self) { route in
                    destinationView(for: route)
                        .toolbar(.hidden, for: .navigationBar)
                        .toolbar(.hidden, for: .tabBar)
                }
        }
        .environmentObject(router)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func destinationView(for route: UserRoute) -> some View {
        switch route {
        case .user:
            UserView()
        case .setting:
            SettingView()
        case .noticeSetting:
            NoticeSettingView(onBack: { router.pop() })
        case .nicknameUpdate:
            NicknameUpdateView()
        case .deleteUser:
            DeleteUserView(store: DeleteUserStore())
        case .genreUpdate(let genreList):
            UserGenreUpdateView(selectedGenreList: genreList)
        case .artistUpdate(let artistList):
            UserArtistUpdateView(selectedArtistList: artistList)
        }
    }
}
