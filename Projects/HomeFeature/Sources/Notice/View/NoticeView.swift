//
//  NoticeView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 1/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import ConcertFeature
import Domain
import LivithDesignSystem

// MARK: - NoticeView

public struct NoticeView: View {

    // MARK: - Property

    @StateObject private var store = NoticeStore()
    @State private var didNavigateToDetail = false

    private let onBack: () -> Void
    private let onSettingTap: () -> Void
    private let onInterestTap: () -> Void
    private let onConcertTap: (Int, SegmentedTabBarType.DetailTab, ConcertInfoSection?) -> Void

    // MARK: - Initializer

    public init(
        onBack: @escaping () -> Void,
        onSettingTap: @escaping () -> Void,
        onInterestTap: @escaping () -> Void,
        onConcertTap: @escaping (Int, SegmentedTabBarType.DetailTab, ConcertInfoSection?) -> Void
    ) {
        self.onBack = onBack
        self.onSettingTap = onSettingTap
        self.onInterestTap = onInterestTap
        self.onConcertTap = onConcertTap
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            navigationBar

            if store.state.isLoading {
                loadingView
            } else if store.state.notifications.isEmpty {
                emptyView
            } else {
                noticeList
                    .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
        .onAppear {
            if didNavigateToDetail {
                didNavigateToDetail = false
                store.send(.refresh)
            } else {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - UIComponents

private extension NoticeView {
    var navigationBar: some View {
        LivithNavigationView(
            type: .back(
                title: Literals.title,
                onBack: onBack,
                rightButtonTitle: Literals.settingButton,
                onRightButtonTap: onSettingTap
            )
        )
    }

    var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(Color.livithColor(.white100))
            Spacer()
        }
    }

    var emptyView: some View {
        VStack(spacing: 0) {
            infoText
                .padding(.horizontal, 16)
                .padding(.top, 12)

            Spacer()

            LivithEmptyView(text: Literals.emptyMessage)

            Spacer()
        }
    }

    var infoText: some View {
        HStack {
            Text(Literals.infoMessage)
                .notosans(.body4Semibold)
                .foregroundStyle(Color.livithColor(.black30))

            Spacer()
        }
    }

    var noticeList: some View {
        ScrollView {
            infoText
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

            LazyVStack(spacing: 12) {
                ForEach(store.state.notifications) { notification in
                    NoticeItemView(
                        title: notification.title,
                        description: notification.content,
                        timeAgo: notification.displayCreatedAt,
                        state: notification.isRead ? .read : .normal,
                        action: {
                            store.send(.markAsRead(id: notification.id))
                            didNavigateToDetail = true
                            if notification.type == .interestConcert {
                                onInterestTap()
                            } else if let targetID = notification.targetID {
                                let (initialTab, initialSection) = mapNotificationTypeToTabAndSection(notification.type)
                                onConcertTap(targetID, initialTab, initialSection)
                            }
                        }
                    )
                    .onAppear {
                        if notification.id == store.state.notifications.last?.id {
                            store.send(.loadNextPage)
                        }
                    }
                }

                if store.state.isLoadingMore {
                    ProgressView()
                        .tint(Color.livithColor(.white100))
                        .padding(.vertical, 16)
                }
            }
            .padding(.horizontal, 4)
        }
        .refreshable {
            await store.refreshAsync()
        }
    }
}

// MARK: - Helper

private extension NoticeView {
    func mapNotificationTypeToTabAndSection(_ type: NotificationType) -> (SegmentedTabBarType.DetailTab, ConcertInfoSection?) {
        switch type {
        case .concertInfoUpdateSetlist:
            return (.setlist, nil)
        case .concertInfoUpdateMD:
            return (.concertInfo, .merchandise)
        case .concertInfoUpdateSchedule, .concertInfoUpdateTicket:
            return (.concertInfo, .schedule)
        case .concertInfoUpdateDetail:
            return (.concertInfo, .concertInfo)
        default:
            return (.artistDetail, nil)
        }
    }
}

// MARK: - Constants

private extension NoticeView {
    enum Literals {
        static let title = "알림"
        static let settingButton = "알림 설정"
        static let infoMessage = "알림은 90일 이후 순차적으로 삭제돼요."
        static let emptyMessage = "아직 공연 소식이 없어요 :(\n알림으로 가장 먼저 알려드릴게요"
    }
}

// MARK: - Preview

#Preview {
    NoticeView(
        onBack: {},
        onSettingTap: {},
        onInterestTap: {},
        onConcertTap: { _, _, _ in }
    )
}
