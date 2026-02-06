//
//  NotificationListView.swift
//  UserFeature
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

// MARK: - NotificationListView

public struct NotificationListView: View {

    // MARK: - Property

    @StateObject private var store = NotificationListStore()

    private let onBack: () -> Void
    private let onConcertTap: (Int) -> Void

    // MARK: - Initializer

    public init(
        onBack: @escaping () -> Void,
        onConcertTap: @escaping (Int) -> Void
    ) {
        self.onBack = onBack
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
                notificationList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - UIComponents

private extension NotificationListView {
    var navigationBar: some View {
        LivithNavigationView(type: .back(title: Literals.title, onBack: onBack))
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
        VStack {
            Spacer()
            Text(Literals.emptyMessage)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.black50))
            Spacer()
        }
    }

    var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.state.notifications) { notification in
                    notificationRow(notification)
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
        }
    }

    func notificationRow(_ notification: NotificationItem) -> some View {
        Button {
            if let targetID = notification.targetID {
                onConcertTap(targetID)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(notification.title)
                        .notosans(.body2Semibold)
                        .foregroundStyle(Color.livithColor(.white100))

                    Spacer()

                    if !notification.isRead {
                        Circle()
                            .fill(Color.livithColor(.yellow60))
                            .frame(width: 8, height: 8)
                    }
                }

                Text(notification.content)
                    .notosans(.body3Regular)
                    .foregroundStyle(Color.livithColor(.black30))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(notification.createdAt)
                    .notosans(.caption1Regular)
                    .foregroundStyle(Color.livithColor(.black50))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                notification.isRead
                    ? Color.livithColor(.black100)
                    : Color.livithColor(.black90)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Constants

private extension NotificationListView {
    enum Literals {
        static let title = "알림"
        static let emptyMessage = "아직 받은 알림이 없어요"
    }
}

// MARK: - Preview

#Preview {
    NotificationListView(onBack: {}, onConcertTap: { _ in })
}
