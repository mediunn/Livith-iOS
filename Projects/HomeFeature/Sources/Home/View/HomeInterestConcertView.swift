//
//  HomeInterestConcertView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import Domain
import LivithFoundation

struct HomeInterestConcertView: View {
    @Environment(\.homeCoordinator) private var coordinator
    @ObservedObject private var store: HomeStore
    @Binding private var isTabBarHidden: Bool
    
    @State private var selectedTab: SegmentedTabBarType.HomeTab = .schedule
    @State private var showBottomSheet: Bool = false
    @State private var showDeleteDialog: Bool = false
    
    init(store: HomeStore, isTabBarHidden: Binding<Bool>) {
        self.store = store
        self._isTabBarHidden = isTabBarHidden
    }
    
    private var interestState: HomeState.InterestConcertState { store.state.interestConcert }
    
    var body: some View {
        mainContent
            .background(.livithColor(.black100))
            .crossDissolve(isPresented: $showDeleteDialog) {
                LivithDangerModal(
                    message: "관심 콘서트를 삭제하시나요?\n언제든 다시 지정할 수 있어요.",
                    confirmTitle: "지금은 삭제할래요",
                    cancelTitle: "잘못 눌렀어요",
                    type: .confirm(onConfirm: handleDeleteConfirm),
                    onCancel: {
                        showDeleteDialog = false
                        isTabBarHidden = false
                    }
                )
            }
            .livithSheet(
                isPresented: $showBottomSheet,
                detents: [.fraction(180.0 / 812.0)]
            ) {
                HomeInterestConcertBottomSheetView(
                    onChangeMainConcert: handleChangeMainConcert,
                    onDeleteConcert: handleDeleteConcert
                )
            }
    }
}

// MARK: - Subviews

private extension HomeInterestConcertView {
    var mainContent: some View {
        VStack(spacing: .zero) {
            LivithNavigationView(type: .logo(
                hasNewNotice: store.state.hasNewNotice,
                onNoticeTap: { coordinator?.push(to: .notice) }
            ))
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: .zero) {
                    textHeaderView
                    
                    InterestConcertCardView(
                        posterURL: interestState.concert?.posterURL,
                        remainDays: interestState.concert?.daysLeft ?? 0,
                        date: formatDate(interestState.concert?.startDate),
                        location: interestState.concert?.venue ?? "",
                        title: interestState.concert?.title ?? "",
                        onMoreInfoTap: handleMoreInfoTap
                    )
                    
                    SegmentedTabBar(type: .home(
                        selectedTab: selectedTab,
                        onTabSelected: { selectedTab = $0 }
                    ))
                    
                    Group {
                        if selectedTab == .schedule {
                            ConcertScheduleTabView(schedules: interestState.scheduleList)
                        } else {
                            ConcertSetlistTabView(
                                setlist: interestState.setlist,
                                songs: interestState.songList,
                                onSongTap: { songID in
                                    handleSongTap(songID: songID)
                                },
                                onMoreTap: { setlistID in
                                    handleSetlistMoreTap(setlistID: setlistID)
                                }
                            )
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                }
            }
            .refreshable {
                await MainActor.run {
                    store.send(.interestConcert(.onRefresh))
                }
            }
        }
    }
    
    var textHeaderView: some View {
        HStack(spacing: .zero) {
            Text("나의 관심 콘서트")
                .notosans(.headSemibold)
                .foregroundStyle(.livithColor(.white100))
                .padding(.top, 24)
                .padding(.leading, 16)
                .padding(.bottom, 20)
            
            Spacer()
            
            LivithTextButton("수정하기") {
                showBottomSheet = true
            }
            .padding(.top, 20)
            .padding([.bottom, .trailing], 16)
        }
    }
}

// MARK: - Helpers

private extension HomeInterestConcertView {
    func handleMoreInfoTap() {
        guard let concertID = interestState.concert?.id else { return }
        coordinator?.showConcertDetail(concertID: concertID)
    }
    
    func handleSongTap(songID: Int) {
        guard let setlistID = interestState.setlist?.id,
              let song = interestState.songList.first(where: { $0.id == songID })
        else {
            return
        }
        coordinator?.showSongDetail(songID: songID, setlistID: setlistID, songTitle: song.title)
    }
    
    func handleSetlistMoreTap(setlistID: Int) {
        guard let concertID = interestState.concert?.id else { return }
        coordinator?.showSetlistDetail(concertID: concertID, setlistID: setlistID)
    }
    
    func handleChangeMainConcert() {
        showBottomSheet = false
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.5))
            coordinator?.push(to: .interest)
        }
    }
    
    func handleDeleteConcert() {
        showBottomSheet = false
        showDeleteDialog = true
    }
    
    func handleDeleteConfirm() {
        showDeleteDialog = false
        isTabBarHidden = false
        
        store.send(.interestConcert(.onDelete))
    }
    
    func formatDate(_ date: Date?) -> String {
        guard let date else { return "" }
        return DateFormatterService.string(from: date, type: .koreanFullDate)
    }
}
