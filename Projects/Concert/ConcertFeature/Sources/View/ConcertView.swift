//
//  ConcertView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import DSKit

public struct ConcertView: View {

    // MARK: - Property

    private let concertID: Int
    private let onDismiss: () -> Void

    @Environment(\.concertCoordinator) private var coordinator

    @ObservedObject private var store: ConcertStore
    @State private var showInterestConfirmDialog: Bool = false

    // MARK: - Initializer

    public init(
        store: ConcertStore = ConcertStore(),
        concertID: Int,
        onDismiss: @escaping () -> Void
    ) {
        self.store = store
        self.concertID = concertID
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    private var showEmptyView: Bool {
        !store.state.isLoading && store.state.concert == nil
    }

    public var body: some View {
        VStack(spacing: 0) {
            ConcertNavigationBar(
                title: store.state.concert?.title ?? "",
                onBack: onDismiss
            )

            if showEmptyView {
                LivithEmptyView(text: "콘서트 정보가 없어요")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            headerSection
                                .id("top")

                            Section {
                                tabContentView
                            } header: {
                                segmentTabBar
                            }
                        }
                        .opacity(store.state.concert != nil ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: store.state.concert != nil)
                    }
                    .onChange(of: store.state.selectedTab) {
                        withAnimation {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
            }
        }
        .background(Color.livithColor(.black100).ignoresSafeArea())
        .livithToast(
            isPresented: Binding(
                get: {
                    if case .failure = store.state.interestStatus { return true }
                    return false
                },
                set: { _ in store.send(.onToastDisappear) }
            ),
            type: .failure,
            message: store.state.interestStatus.message
        )
        .livithToast(
            isPresented: Binding(
                get: {
                    if case .success = store.state.interestStatus { return true }
                    return false
                },
                set: { _ in store.send(.onToastDisappear) }
            ),
            type: .success,
            message: store.state.interestStatus.message
        )
        .livithToast(
            isPresented: Binding(
                get: { store.state.fetchError != nil },
                set: { _ in store.send(.onFetchErrorDismiss) }
            ),
            type: .failure,
            message: store.state.fetchError ?? ""
        )
        .overlay {
            if showInterestConfirmDialog {
                LivithConfirmDialog(
                    message: "관심 콘서트를 변경하시겠어요?",
                    confirmTitle: "변경할래요",
                    cancelTitle: "취소할래요",
                    onConfirm: {
                        showInterestConfirmDialog = false
                        store.send(.interestButtonTapped)
                    },
                    onCancel: {
                        showInterestConfirmDialog = false
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showInterestConfirmDialog)
        .overlay {
            if store.state.showTicketReturnBanner {
                TicketReturnBanner(
                    onSettingTapped: {
                        store.send(.onTicketBannerDismiss)
                        showInterestConfirmDialog = true
                    },
                    onDismiss: {
                        store.send(.onTicketBannerDismiss)
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.state.showTicketReturnBanner)
        .onAppear {
            store.send(.onAppear(concertID: concertID))
            coordinator?.onTicketSiteReturn = { [weak store] in
                store?.send(.onTicketSiteReturn)
            }
        }
    }
}

// MARK: - Header Section

private extension ConcertView {
    var headerSection: some View {
        ZStack(alignment: .bottom) {
            posterSection
                .frame(maxWidth: .infinity)
                .frame(height: 340)
                .clipped()

            concertInfoSection
                .padding(.bottom, 30)
        }
    }
}

// MARK: - Segment TabBar

private extension ConcertView {
    var segmentTabBar: some View {
        ConcertSegmentTabBar(
            selectedTab: store.state.selectedTab,
            communityCount: store.state.communityCount,
            onTabSelected: { tab in
                withAnimation(.easeInOut(duration: 0.2)) {
                    store.send(.tabSelected(tab))
                }
            }
        )
        .frame(maxWidth: .infinity)
        .background(Color.livithColor(.black100))
    }
}

// MARK: - Tab Content

private extension ConcertView {
    @ViewBuilder
    var tabContentView: some View {
        switch store.state.selectedTab {
        case .artistDetail:
            ArtistDetailTabView(
                artist: store.state.artist,
                introduction: store.state.concert?.introduction ?? "",
                fanCultures: store.state.fanCultures
            )
            .background(.livithColor(.black100))
        case .concertInfo:
            ConcertInfoTabView(
                ticketingOffice: store.state.concert?.ticketingOffice,
                ticketingOfficeURL: store.state.concert?.ticketingOfficeURL,
                scheduleList: store.state.schedules,
                concertInfoList: store.state.concertInfoList,
                merchandiseList: store.state.merchandiseList
            )
            .background(.livithColor(.black100))
        case .setlist:
            SetlistTabView()
        case .community:
            CommunityTabView()
        }
    }
}

// MARK: - Poster Section

private extension ConcertView {
    var posterSection: some View {
        ZStack(alignment: .topTrailing) {
            posterImage
                .frame(height: 337)

            InterestButton {
                showInterestConfirmDialog = true
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .clipped()
    }

    var posterImage: some View {
        AsyncImageView(
            url: store.state.concert?.posterURL,
            showGradient: true
        ) {
            Image.livithImage(.concertCardEmpty)
                .resizable()
        }
    }
}

// MARK: - Concert Info Section

private extension ConcertView {
    var concertInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label = store.state.concert?.label, !label.isEmpty {
                PopularBadge(text: label)
                    .padding(.bottom, 10)
            }

            concertTitle
                .padding(.bottom, 10)

            artistName
                .padding(.bottom, 10)

            dateInfo
                .padding(.bottom, 4)

            venueInfo
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }

    var concertTitle: some View {
        Text(store.state.concert?.title ?? "")
            .notosans(.headSemibold)
            .foregroundStyle(Color.livithColor(.white100))
    }

    var artistName: some View {
        Text(store.state.concert?.artist ?? "")
            .notosans(.body2Medium)
            .foregroundStyle(Color.livithColor(.black30))
    }

    var dateInfo: some View {
        HStack(spacing: 4) {
            Image.livithIcon(.calendarLine)
                .resizable()
                .frame(width: 24, height: 24)

            Text(store.state.formattedDateRange)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
        }
    }

    var venueInfo: some View {
        HStack(spacing: 4) {
            Image.livithIcon(.locationLine)
                .resizable()
                .frame(width: 24, height: 24)

            Text(store.state.concert?.venue ?? "")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
        }
    }
}

#Preview {
    ConcertView(
        store: ConcertStore(),
        concertID: 1,
        onDismiss: {}
    )
}
