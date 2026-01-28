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
                    isTabBarHidden: isTabBarHidden,
                    onSetting: { [weak self] in self?.push(to: .setting) },
                    onNicknameEdit: { [weak self] in self?.push(to: .nicknameUpdate) },
                    onGenreSetting: { [weak self] in self?.push(to: .genreSetting) },
                    onArtistSetting: { [weak self] in self?.push(to: .artistSetting) }
                )
            )

        case .setting:
            return UIHostingController(
                rootView: SettingView(
                    onBack: { [weak self] in self?.pop() },
                    onNoticeSetting: { [weak self] in self?.push(to: .noticeSetting) },
                    onDeleteUser: { [weak self] in self?.push(to: .deleteUser) }
                )
            )

        case .noticeSetting:
            return UIHostingController(
                rootView: NoticeSettingView(
                    onBack: { [weak self] in self?.pop() }
                )
            )

        case .nicknameUpdate:
            return UIHostingController(
                rootView: NicknameUpdateView(
                    onDismiss: { [weak self] in self?.pop() },
                    onSuccess: { [weak self] _ in self?.pop() }
                )
            )

        case .deleteUser:
            return UIHostingController(
                rootView: DeleteUserView(
                    store: DeleteUserStore(),
                    onDismiss: { [weak self] in self?.pop() }
                )
            )

        case .genreSetting:
            // TODO: 선호 장르 설정 화면 구현 필요
            return UIViewController()

        case .artistSetting:
            // TODO: 선호 아티스트 설정 화면 구현 필요
            return UIViewController()
        }
    }
}
