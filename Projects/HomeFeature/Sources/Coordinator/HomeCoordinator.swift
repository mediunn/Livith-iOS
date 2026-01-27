//
//  HomeCoordinator.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertFeature

import LivithDesignSystem
import Coordinator

final class HomeCoordinator: Coordinator {
    typealias R = HomeRoute

    let navigationController: UINavigationController

    private let nickname: Binding<String>
    private var concertCoordinator: ConcertCoordinator?
    private let isTabBarHidden: Binding<Bool>
    private let showToast: ((LivithToastType, String) -> Void)?

    init(nickname: Binding<String>, isTabBarHidden: Binding<Bool>, showToast: ((LivithToastType, String) -> Void)? = nil) {
        self.navigationController = UINavigationController()
        self.nickname = nickname
        self.isTabBarHidden = isTabBarHidden
        self.showToast = showToast

        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        push(to: .home, animated: false)
    }

    func buildViewController(for route: R) -> UIViewController {
        switch route {
        case .home:
            return UIHostingController(rootView: HomeView(nickname: nickname, isTabBarHidden: isTabBarHidden, showToast: showToast).environment(\.homeCoordinator, self))

        case .interest:
            return UIHostingController(rootView: InterestConcertSearchView().environment(\.homeCoordinator, self))

        case .interestComplete(posterURL: let url, title: let title, prefetchedImage: let image):
            return UIHostingController(
                rootView: InteresetConcertCompleteView(
                    concertPosterURL: url,
                    concertTitle: title,
                    prefetchedImage: image
                )
                .environment(\.homeCoordinator, self)
            )

        case .notice:
            return UIHostingController(
                rootView: NoticeView(
                    onBack: { [weak self] in self?.pop() },
                    onSettingTap: { /* TODO: 알림 설정 화면 */ }
                )
                .environment(\.homeCoordinator, self)
            )
        }
    }

    func showConcertDetail(concertID: Int) {
        let coordinator = ConcertCoordinator(
            navigationController: navigationController,
            onDismiss: { [weak self] in
                self?.concertCoordinator = nil
            }
        )
        self.concertCoordinator = coordinator
        coordinator.start(concertID: concertID)
    }

    func showSongDetail(songID: Int, setlistID: Int, songTitle: String) {
        let coordinator = ConcertCoordinator(
            navigationController: navigationController,
            onDismiss: { [weak self] in
                self?.concertCoordinator = nil
            }
        )
        self.concertCoordinator = coordinator
        coordinator.push(to: .songLyrics(songID: songID, setlistID: setlistID, songTitle: songTitle))
    }

    func showSetlistDetail(concertID: Int, setlistID: Int) {
        let coordinator = ConcertCoordinator(
            navigationController: navigationController,
            onDismiss: { [weak self] in
                self?.concertCoordinator = nil
            }
        )
        self.concertCoordinator = coordinator
        coordinator.push(to: .setlistDetail(concertID: concertID, setlistID: setlistID))
    }
}
