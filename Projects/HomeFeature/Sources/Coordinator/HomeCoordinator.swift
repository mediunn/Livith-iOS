//
//  HomeCoordinator.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertFeature
import Coordinator
import LivithDesignSystem
import UserFeature

final class HomeCoordinator: Coordinator {
    typealias R = HomeRoute

    let navigationController: UINavigationController
    
    private var concertCoordinator: ConcertCoordinator?
    private let isTabBarHidden: Binding<Bool>

    init(isTabBarHidden: Binding<Bool>) {
        self.navigationController = UINavigationController()
        self.isTabBarHidden = isTabBarHidden

        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        push(to: .home, animated: false)
    }

    func buildViewController(for route: R) -> UIViewController {
        switch route {
        case .home:
            return UIHostingController(rootView: HomeView(isTabBarHidden: isTabBarHidden).environment(\.homeCoordinator, self))

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
                    onSettingTap: { [weak self] in self?.push(to: .noticeSetting) },
                    onInterestTap: { [weak self] in self?.push(to: .interest) },
                    onConcertTap: { [weak self] concertID, initialTab in
                        self?.showConcertDetail(concertID: concertID, initialTab: initialTab)
                    }
                )
                .environment(\.homeCoordinator, self)
            )

        case .noticeSetting:
            return UIHostingController(
                rootView: NoticeSettingView(
                    onBack: { [weak self] in self?.pop() }
                )
                .environment(\.homeCoordinator, self)
            )
            
        case .recommendedConcertList(let concertList):
            let vc = UIHostingController(
                rootView: RecommendedConcertGridView(concertList: concertList)
                    .environment(\.homeCoordinator, self)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
            
        case .preferredGenreUpdate:
            let vc = UIHostingController(
                rootView: GenreUpdateView().environment(\.homeCoordinator, self)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
            
        case .preferredAritstUpdate(let genreList):
            let vc = UIHostingController(
                rootView: ArtistUpdateView(selectedGenreList: genreList).environment(\.homeCoordinator, self)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }

    func showConcertDetail(concertID: Int, initialTab: SegmentedTabBarType.DetailTab = .artistDetail) {
        let coordinator = ConcertCoordinator(
            navigationController: navigationController,
            onDismiss: { [weak self] in
                self?.concertCoordinator = nil
            }
        )
        self.concertCoordinator = coordinator
        coordinator.start(concertID: concertID, initialTab: initialTab)
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
