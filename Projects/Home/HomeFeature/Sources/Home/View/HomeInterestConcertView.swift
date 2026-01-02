//
//  HomeInterestConcertView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeDomain

struct HomeInterestConcertView: View {
    @Environment(\.homeCoordinator) private var coordinator
    @ObservedObject private var store: HomeInterestConcertStore
    
    @State private var selectedTab: InterestConcertTab = .schedule
    @State private var showBottomSheet: Bool = false
    @State private var showDeleteDialog: Bool = false
    
    private let setlist: SetlistItem = .sample
    private let songs: SongList = .sample
    
    init(store: HomeInterestConcertStore) {
        self.store = store
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mainContent
                .background(.livithColor(.black100))
            
            customBottomSheet
                .ignoresSafeArea()
            
            deleteDialog
        }
        .animation(.easeInOut, value: showDeleteDialog)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Subviews

private extension HomeInterestConcertView {
    var mainContent: some View {
        VStack(spacing: .zero) {
            LivithLogoHeaderView()
            
            ScrollView {
                VStack(spacing: .zero) {
                    textHeaderView
                    
                    InterestConcertCardView(
                        posterURL: store.state.interestConcert.posterURL,
                        remainDays: store.state.interestConcert.daysLeft,
                        date: store.state.interestConcert.startDate,
                        location: store.state.interestConcert.venue,
                        title: store.state.interestConcert.title
                    )
                    
                    SegmentTabBar(
                        segmentTitles: InterestConcertTab.allCases.map { $0.title },
                        selectedIndex: selectedTab.rawValue,
                        onTabSelected: updateSelectedTab(from:)
                    )
                    
                    Group {
                        if selectedTab == .schedule {
                            ConcertScheduleTabView(schedules: store.state.scheduleList)
                        } else {
                            ConcertSetlistTabView(
                                selist: setlist,
                                songs: songs,
                                onSongTap: { _ in },
                                onMoreTap: { _ in }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .refreshable {
                
            }
        }
    }
    
    var customBottomSheet: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(showBottomSheet ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture { showBottomSheet = false }
                .allowsHitTesting(showBottomSheet)
                .animation(.easeInOut(duration: 0.3), value: showBottomSheet)
            
            HomeInterestConcertBottomSheetView(
                onChangeMainConcert: handleChangeMainConcert,
                onDeleteConcert: handleDeleteConcert
            )
            .background(.livithColor(.black90))
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 24,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 24
                )
            )
            .offset(y: showBottomSheet ? 0 : UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 0.3), value: showBottomSheet)
        }
    }
    
    var deleteDialog: some View {
        Group {
            if showDeleteDialog {
                LivithConfirmDialog(
                    message: "관심 콘서트를 삭제하시나요?\n언제든 다시 지정할 수 있어요.",
                    confirmTitle: "지금은 삭제할래요",
                    cancelTitle: "잘못 눌렀어요",
                    onConfirm: handleDeleteConfirm,
                    onCancel: { showDeleteDialog = false }
                )
                .transition(.opacity)
            }
        }
    }
    
    var textHeaderView: some View {
        HStack(spacing: .zero) {
            Text("나의 관심 콘서트")
                .notosans(.headSemibold)
                .foregroundStyle(.livithColor(.white100))
                .padding(.leading, 16)
            
            Spacer()
            
            Button { showBottomSheet = true } label: {
                Text("수정하기")
                    .notosans(.body4Regular)
                    .foregroundStyle(.livithColor(.black50))
                    .padding(8)
            }
            .padding(.top, 20)
            .padding([.bottom, .trailing], 16)
        }
    }
}

// MARK: - Helpers

private extension HomeInterestConcertView {
    func handleChangeMainConcert() {
        showBottomSheet = false
        // TODO: 코디네이터로 관심콘서트 설정 화면 이동하기
    }
    
    func handleDeleteConcert() {
        showBottomSheet = false
        showDeleteDialog = true
    }
    
    func handleDeleteConfirm() {
        showDeleteDialog = false
        // TODO: 관심 콘서트 삭제 요청
    }
    
    func updateSelectedTab(from index: Int) {
        if let tab = InterestConcertTab(rawValue: index) {
            selectedTab = tab
        }
    }
}
