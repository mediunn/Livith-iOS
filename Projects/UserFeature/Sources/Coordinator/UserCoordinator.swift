//
//  UserCoordinator.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/28/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Coordinator

final class UserCoordinator: Coordinator {
    typealias R = UserRoute

    let navigationController: UINavigationController

    private let isTabBarHidden: Binding<Bool>

    init(isTabBarHidden: Binding<Bool>) {
        self.navigationController = UINavigationController()
        self.isTabBarHidden = isTabBarHidden

        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        push(to: .user, animated: false)
    }

    func buildViewController(for route: R) -> UIViewController {
        switch route {
        case .user:
            return UIHostingController(
                rootView: UserView(
                    isTabBarHidden: isTabBarHidden
                )
                .environment(\.userCoordinator, self)
            )

        case .setting:
            return UIHostingController(
                rootView: SettingView()
                .environment(\.userCoordinator, self)
            )

        case .noticeSetting:
            return UIHostingController(
                rootView: NoticeSettingView(
                    onBack: { [weak self] in self?.pop() }
                )
            )

        case .nicknameUpdate:
            return UIHostingController(
                rootView: NicknameUpdateView()
                .environment(\.userCoordinator, self)
            )

        case .deleteUser:
            return UIHostingController(
                rootView: DeleteUserView(
                    store: DeleteUserStore()
                )
                .environment(\.userCoordinator, self)
            )

        case .genreUpdate(let genreList):
            let vc = UIHostingController(
                rootView: UserGenreUpdateView(
                    selectedGenreList: genreList
                )
                .environment(\.userCoordinator, self)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .artistUpdate(let artistList):
            let vc = UIHostingController(
                rootView: UserArtistUpdateView(
                    selectedArtistList: artistList
                )
                .environment(\.userCoordinator, self)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }
}
