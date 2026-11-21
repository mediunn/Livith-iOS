//
//  UserCoordinatorView.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/28/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import NicknameEditFeature

public struct UserCoordinatorView: View {
    @StateObject private var router: UserRouter
    private let sessionNickname: SessionNickname?

    public init(
        sessionNickname: SessionNickname? = nil,
        onNavigateToHome: (() -> Void)? = nil
    ) {
        self.sessionNickname = sessionNickname
        _router = StateObject(
            wrappedValue: UserRouter(
                onNavigateToHome: onNavigateToHome ?? {}
            )
        )
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            UserView(nickname: sessionNickname?.nickname)
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
            UserView(nickname: sessionNickname?.nickname)
        case .setting:
            SettingView()
        case .noticeSetting:
            NoticeSettingView(onBack: { router.pop() })
        case .nicknameUpdate:
            NicknameUpdateView(sessionNickname: sessionNickname)
        case .deleteUser:
            DeleteUserView(store: DeleteUserStore())
        case .genreUpdate(let genreList):
            UserGenreUpdateView(selectedGenreList: genreList)
        case .artistUpdate(let artistList):
            UserArtistUpdateView(selectedArtistList: artistList)
        }
    }
}
