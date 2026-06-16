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

    init() {
        self.navigationController = UINavigationController()
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        push(to: .home, animated: false)
    }
    
    func buildViewController(for route: R) -> UIViewController {
        switch route {
        case .home:
            return UIHostingController(rootView: HomeView().environment(\.homeCoordinator, self))
            
        case .interestConcertSetting(let mode):
            let vc = UIHostingController(
                rootView: InterestConcertSettingView(mode: mode).environment(\.homeCoordinator, self)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .interestConcertList:
            let vc = UIHostingController(
                rootView: InterestConcertListView().environment(\.homeCoordinator, self)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
             
        case .notice:
            return UIHostingController(
                rootView: NoticeView(
                    onBack: { [weak self] in self?.pop() },
                    onSettingTap: { [weak self] in self?.push(to: .noticeSetting) },
                    onInterestTap: { [weak self] in self?.push(to: .interestConcertSetting(mode: .update)) },
                    onConcertTap: { [weak self] concertID, initialTab, initialSection in
                        self?.showConcertDetail(concertID: concertID, initialTab: initialTab, initialSection: initialSection)
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
            
        case .preferredArtistUpdate(let genreList):
            let vc = UIHostingController(
                rootView: ArtistUpdateView(selectedGenreList: genreList).environment(\.homeCoordinator, self)
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }
    
    // MARK: - Concert (임시 어댑터, Plan 2에서 정식 Router로 대체)

    func showConcertDetail(
        concertID: Int,
        initialTab: SegmentedTabBarType.DetailTab = .artistDetail,
        initialSection: ConcertInfoSection? = nil
    ) {
        let view = ConcertCoordinatorView(
            concertID: concertID,
            initialTab: initialTab,
            initialSection: initialSection
        )
        let hosting = UIHostingController(rootView: view)
        hosting.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(hosting, animated: true)
    }
}
