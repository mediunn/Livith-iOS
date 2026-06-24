//
//  UserRouter.swift
//  UserFeature
//
//  Created by on 6/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Coordinator

final class UserRouter: Router<UserRoute> {
    private let onNavigateToHome: () -> Void
    // TODO: 향후 Store 상태 변경으로 이전 예정
    var onGenreUpdateSuccess: (() -> Void)?
    // TODO: 향후 Store 상태 변경으로 이전 예정
    var onArtistUpdateSuccess: (() -> Void)?

    init(
        onNavigateToHome: @escaping () -> Void = {}
    ) {
        self.onNavigateToHome = onNavigateToHome
        super.init()
    }

    func navigateToHome() {
        onNavigateToHome()
    }

    // TODO: 향후 Store 상태 변경으로 이전 예정
    func genreUpdateSuccess() {
        onGenreUpdateSuccess?()
    }

    // TODO: 향후 Store 상태 변경으로 이전 예정
    func artistUpdateSuccess() {
        onArtistUpdateSuccess?()
    }
}
