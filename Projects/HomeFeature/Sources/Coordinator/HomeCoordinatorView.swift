//
//  HomeCoordinatorView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertFeature
import Coordinator
import Domain
import LivithDesignSystem
import NicknameEditFeature
import ShareFeature
import UserFeature

// MARK: - HomeRouter

typealias HomeRouter = Router<HomeRoute>

// MARK: - HomeCoordinatorView

public struct HomeCoordinatorView: View {

    // MARK: - Property

    @Environment(\.concertCatalogRepository) private var concertCatalogRepository
    @Environment(\.searchRepository) private var searchRepository
    @Environment(\.interestConcertRepository) private var interestConcertRepository
    @Environment(\.concertRequestRepository) private var concertRequestRepository
    @StateObject private var router: HomeRouter

    @State private var showConcertRequestSuccessToast: Bool = false
    @State private var showInterestSettingSuccessToast = false
    @State private var savedInterestSettingMode: InterestConcertSettingMode = .initialSetup

    @Binding private var deepLinkConcertID: Int?
    @Binding private var deepLinkInitialTab: SegmentedTabBarType.DetailTab
    @Binding private var deepLinkInitialSection: ConcertInfoSection?
    @Binding private var deepLinkShowInterest: Bool
    @Binding private var deepLinkInstagramURL: URL?

    private let sessionNickname: SessionNickname

    // MARK: - Initializer

    public init(
        deepLinkConcertID: Binding<Int?> = .constant(nil),
        deepLinkInitialTab: Binding<SegmentedTabBarType.DetailTab> = .constant(.artistDetail),
        deepLinkInitialSection: Binding<ConcertInfoSection?> = .constant(nil),
        deepLinkShowInterest: Binding<Bool> = .constant(false),
        deepLinkInstagramURL: Binding<URL?> = .constant(nil),
        sessionNickname: SessionNickname
    ) {
        _router = StateObject(wrappedValue: HomeRouter())
        self._deepLinkConcertID = deepLinkConcertID
        self._deepLinkInitialTab = deepLinkInitialTab
        self._deepLinkInitialSection = deepLinkInitialSection
        self._deepLinkShowInterest = deepLinkShowInterest
        self._deepLinkInstagramURL = deepLinkInstagramURL
        self.sessionNickname = sessionNickname
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(path: $router.path) {
            HomeView(sessionNickname: sessionNickname)
                .navigationDestination(for: HomeRoute.self) { route in
                    destinationView(for: route)
                        .toolbar(.hidden, for: .tabBar, .navigationBar)
                }
        }
        .environmentObject(router)
        .ignoresSafeArea()
        .livithToast(
            isPresented: $showConcertRequestSuccessToast,
            type: .success,
            message: Literals.concertRequestSuccessToast
        )
        .livithToast(
            isPresented: $showInterestSettingSuccessToast,
            type: .success,
            message: savedInterestSettingMode.successMessage
        )
        .onChange(of: deepLinkConcertID) { newValue in
            if let concertID = newValue {
                router.popToRoot()
                router.push(.concertDetail(
                    concertID: concertID,
                    initialTab: deepLinkInitialTab,
                    initialSection: deepLinkInitialSection
                ))
                deepLinkConcertID = nil
                deepLinkInitialTab = .artistDetail
                deepLinkInitialSection = nil
            }
        }
        .onChange(of: deepLinkShowInterest) { newValue in
            if newValue {
                router.popToRoot()
                router.push(.interestConcertSetting(mode: .update))
                deepLinkShowInterest = false
            }
        }
        .onChange(of: deepLinkInstagramURL) { newValue in
            if let sourceURL = newValue {
                router.popToRoot()
                router.push(.instagramMatchConfirm(sourceURL: sourceURL))
                deepLinkInstagramURL = nil
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: HomeRoute) -> some View {
        switch route {
        case .home:
            HomeView(sessionNickname: sessionNickname)
        case .interestConcertSetting(let mode):
            if let concertCatalogRepository, let searchRepository, let interestConcertRepository {
                InterestConcertSettingView(
                    mode: mode,
                    concertCatalogRepository: concertCatalogRepository,
                    searchRepository: searchRepository,
                    interestConcertRepository: interestConcertRepository,
                    onSaveSuccess: {
                        savedInterestSettingMode = mode
                        router.popToRoot()
                        showInterestSettingSuccessToast = true
                    }
                )
            } else {
                ContentUnavailableView {
                    Label("관심 콘서트 설정을 열 수 없어요", systemImage: "exclamationmark.circle")
                } description: {
                    Text("이전 화면으로 돌아가 주세요.")
                } actions: {
                    Button("돌아가기") { router.pop() }
                }
            }
        case .interestConcertList:
            if let interestConcertRepository {
                InterestConcertListView(repository: interestConcertRepository)
            } else {
                ContentUnavailableView {
                    Label("관심 콘서트 목록을 열 수 없어요", systemImage: "exclamationmark.circle")
                } description: {
                    Text("이전 화면으로 돌아가 주세요.")
                } actions: {
                    Button("돌아가기") { router.pop() }
                }
            }
        case .notice:
            NoticeView(
                onBack: { router.pop() },
                onSettingTap: { router.push(.noticeSetting) },
                onInterestTap: { router.push(.interestConcertSetting(mode: .update)) },
                onConcertTap: { concertID, initialTab, initialSection in
                    router.push(.concertDetail(
                        concertID: concertID,
                        initialTab: initialTab,
                        initialSection: initialSection
                    ))
                }
            )
        case .noticeSetting:
            NoticeSettingView(onBack: { router.pop() })
        case .recommendedConcertList(let concertList):
            RecommendedConcertGridView(concertList: concertList)
        case .preferredGenreUpdate:
            GenreUpdateView()
        case .preferredArtistUpdate(let selectedGenreList):
            ArtistUpdateView(selectedGenreList: selectedGenreList)
        case .concertDetail(let concertID, let initialTab, let initialSection):
            ConcertCoordinatorView(
                concertID: concertID,
                initialTab: initialTab,
                initialSection: initialSection
            )
        case .instagramMatchConfirm(let sourceURL):
            InstagramMatchConfirmView(sourceURL: sourceURL)
        case .instagramManualSearch(let context):
            InstagramManualSearchView(context: context)
        case .concertRequest:
            if let concertRequestRepository {
                ConcertRequestView(
                    repository: concertRequestRepository,
                    onDismiss: { router.pop() },
                    onRequestSuccess: {
                        router.popToRoot()
                        showConcertRequestSuccessToast = true
                    }
                )
            } else {
                ContentUnavailableView {
                    Label("공연 요청 화면을 열 수 없어요", systemImage: "exclamationmark.circle")
                } description: {
                    Text("이전 화면으로 돌아가 주세요.")
                } actions: {
                    Button("돌아가기") { router.pop() }
                }
            }
        }
    }
}

// MARK: - Literals

private extension HomeCoordinatorView {
    enum Literals {
        static let concertRequestSuccessToast = "정보가 요청되었어요"
    }
}
