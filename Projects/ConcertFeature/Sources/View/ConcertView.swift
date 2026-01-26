//
//  ConcertView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

public struct ConcertView: View {

    // MARK: - Property

    private let concertID: Int
    private let onDismiss: () -> Void

    @Environment(\.concertCoordinator) private var coordinator

    @ObservedObject private var store: ConcertStore
    @StateObject private var communityStore: CommunityStore = CommunityStore()
    @State private var showInterestConfirmDialog: Bool = false
    @State private var isExceedingLineLimit: Bool = false
    @State private var isExceedingCharacterLimit: Bool = false

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
            LivithNavigationView(
                type: .back(title: store.state.concert?.title ?? "", onBack: onDismiss)
            )

            if showEmptyView {
                emptyContentView
            } else {
                scrollContent
                commentInputSection
            }
        }
        .background(Color.livithColor(.black100).ignoresSafeArea())
        .livithToast(
            isPresented: Binding(
                get: { toastInfo != nil },
                set: { if !$0 { dismissCurrentToast() } }
            ),
            type: toastInfo?.type ?? .failure,
            message: toastInfo?.message ?? "",
            topPadding: 16
        )
        .livithToast(
            isPresented: $isExceedingLineLimit,
            type: .failure,
            message: "댓글은 15줄을 초과할 수 없어요",
            duration: nil,
            topPadding: 16
        )
        .livithToast(
            isPresented: $isExceedingCharacterLimit,
            type: .failure,
            message: "댓글은 400자를 초과할 수 없어요",
            duration: nil,
            topPadding: 16
        )
        .crossDissolve(isPresented: $showInterestConfirmDialog, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: "관심 콘서트를 설정하시겠어요?",
                confirmTitle: "설정할래요",
                cancelTitle: "취소할래요",
                type: .confirm(onConfirm: {
                    showInterestConfirmDialog = false
                    store.send(.interestButtonTapped)
                }),
                onCancel: {
                    showInterestConfirmDialog = false
                }
            )
        }
        .crossDissolve(isPresented: isDeleteDialogPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: "댓글을 삭제하시겠어요?",
                confirmTitle: "지금은 삭제할래요",
                cancelTitle: "잘못 눌렀어요",
                type: .confirm(onConfirm: {
                    communityStore.send(.confirmDelete)
                }),
                onCancel: {
                    communityStore.send(.dismissDialog)
                }
            )
        }
        .crossDissolve(isPresented: isReportDialogPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: "댓글을 신고하시겠어요?",
                confirmTitle: "신고할래요",
                cancelTitle: "잘못 눌렀어요",
                type: .report(onConfirm: { content in
                    communityStore.send(.confirmReport(content: content))
                }),
                onCancel: {
                    communityStore.send(.dismissDialog)
                }
            )
        }
        .overlay { ticketReturnBannerOverlay }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.state.showTicketReturnBanner)
        .onAppear {
            store.send(.onAppear(concertID: concertID))
            communityStore.send(.onAppear(concertID: concertID))
            coordinator?.onTicketSiteReturn = { [weak store] in
                store?.send(.onTicketSiteReturn)
            }
        }
        .onDisappear {
            coordinator?.onTicketSiteReturn = nil
        }
    }
}

// MARK: - Main Content

private extension ConcertView {
    var emptyContentView: some View {
        LivithEmptyView(text: "콘서트 정보가 없어요")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var scrollContent: some View {
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
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onChange(of: store.state.selectedTab) {
                withAnimation {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
            .onChange(of: communityStore.state.toastState) { _, newValue in
                if case .success(let message) = newValue, message.contains("작성") {
                    withAnimation {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var commentInputSection: some View {
        if store.state.selectedTab == .community {
            CommentInputView(
                text: Binding(
                    get: { communityStore.state.commentText },
                    set: { communityStore.send(.updateCommentText($0)) }
                ),
                isExceedingLineLimit: $isExceedingLineLimit,
                isExceedingCharacterLimit: $isExceedingCharacterLimit,
                isSubmitting: communityStore.state.isSubmitting,
                onSubmit: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    communityStore.send(.submitComment)
                }
            )
        }
    }
}

// MARK: - Computed Bindings

private extension ConcertView {
    var isDeleteDialogPresented: Binding<Bool> {
        Binding(
            get: { 
                if case .delete = communityStore.state.dialogState { return true }
                return false
            },
            set: { if !$0 { communityStore.send(.dismissDialog) } }
        )
    }
    
    var isReportDialogPresented: Binding<Bool> {
        Binding(
            get: { 
                if case .report = communityStore.state.dialogState { return true }
                return false
            },
            set: { if !$0 { communityStore.send(.dismissDialog) } }
        )
    }
}

// MARK: - Banner Overlays

private extension ConcertView {

    @ViewBuilder
    var ticketReturnBannerOverlay: some View {
        if store.state.showTicketReturnBanner {
            LivithSnackBar(
                message: "웹사이트를 보셨나요?\n관심 콘서트 설정하고 공연 알림을 받으세요",
                actionTitle: "콘서트 설정",
                onActionTapped: {
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
        SegmentedTabBar(type: .detail(
            selectedTab: store.state.selectedTab,
            communityCount: communityStore.state.totalCount,
            onTabSelected: { tab in
                withAnimation(.easeInOut(duration: 0.2)) {
                    store.send(.tabSelected(tab))
                }
            }
        ))
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
            .frame(maxWidth: UIScreen.main.bounds.width)
            .background(.livithColor(.black100))
        case .setlist:
            SetlistTabView(concertID: store.state.concertID, setlistList: store.state.setlistList)
                .frame(maxWidth: UIScreen.main.bounds.width)
                .background(.livithColor(.black100))
        case .community:
            CommunityTabView(store: communityStore)
        }
    }
}

// MARK: - Poster Section

private extension ConcertView {
    var posterSection: some View {
        ZStack(alignment: .topTrailing) {
            posterImage
                .frame(height: 337)

            if !store.state.isCurrentConcertInterested {
                LivithActionButton("관심 콘서트 설정하기", type: .plus) {
                    showInterestConfirmDialog = true
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
            }
        }
        .clipped()
    }

    var posterImage: some View {
        AsyncImageView(
            url: store.state.concert?.posterURL,
            showGradient: false
        ) {
            Image.livithImage(.concertCardEmpty)
                .resizable()
        }
        .overlay {
            Color.black.opacity(0.7)
        }
    }
}

// MARK: - Concert Info Section

private extension ConcertView {
    var concertInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label = store.state.concert?.label, !label.isEmpty {
                LivithIconBadge.popular(label)
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
        HStack(alignment: .top, spacing: 4) {
            Image.livithIcon(.locationLine)
                .resizable()
                .frame(width: 24, height: 24)

            Text(store.state.concert?.venue ?? "")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
        }
    }
}

// MARK: - Toast

private extension ConcertView {
    var toastInfo: (isPresented: Bool, type: LivithToastType, message: String)? {
        if let fetchError = store.state.fetchError {
            return (true, .failure, fetchError)
        }

        switch store.state.interestStatus {
        case .success(let msg):
            return (true, .success, msg)
        case .failure(let msg):
            return (true, .failure, msg)
        default:
            break
        }

        switch communityStore.state.toastState {
        case .success(let msg):
            return (true, .success, msg)
        case .failure(let msg):
            return (true, .failure, msg)
        case .none:
            break
        }

        return nil
    }

    func dismissCurrentToast() {
        if store.state.fetchError != nil {
            store.send(.onFetchErrorDismiss)
        } else if store.state.interestStatus != .idle && store.state.interestStatus != .inProgress {
            store.send(.onToastDisappear)
        } else if communityStore.state.toastState != .none {
            communityStore.send(.dismissToast)
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
