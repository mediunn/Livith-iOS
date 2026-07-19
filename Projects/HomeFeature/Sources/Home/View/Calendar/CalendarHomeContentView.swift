//
//  CalendarHomeContentView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/17/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct CalendarHomeContentView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter
    @ObservedObject var store: CalendarHomeStore

    @State private var showSelectionBlockedToast = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: .zero) {
                    if !store.state.isLoadFailed {
                        CalendarFilterBarView(store: store)
                    }

                    calendarBody
                }
            }
            .scrollIndicators(.never)
            .refreshable {
                await store.performRefresh()
            }

            #if DEBUG
            debugModalTriggers
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
        .onChange(of: store.state.selectionBlockedToastTrigger) { _, newValue in
            guard newValue > 0 else { return }
            showSelectionBlockedToast = true
        }
        .onDisappear {
            dismissSelectionBlockedToast()
        }
        .livithToast(
            isPresented: selectionBlockedToastBinding,
            type: .failure,
            message: store.state.selectionBlockedToastMessage
        )
        .crossDissolve(isPresented: dayScheduleModalBinding, dismissOnTapOutside: true) {
            CalendarDayScheduleModalView(
                dayTitle: store.state.selectedDayTitle,
                items: store.state.dayScheduleItems,
                onDismiss: { store.send(.dayScheduleModalDismissed) },
                onInterestSettingTap: {
                    store.send(.dayScheduleModalDismissed)
                    homeRouter.push(.interestConcertSetting(mode: .update))
                }
            )
        }
    }
}

// MARK: - UIComponents

private extension CalendarHomeContentView {
    @ViewBuilder
    var calendarBody: some View {
        if store.state.isLoadFailed {
            LivithEmptyView(text: CalendarHomeStore.Constants.loadFailedEmptyMessage)
                .frame(maxWidth: .infinity)
                .containerRelativeFrame(.vertical)
        } else {
            CalendarWebView()
                .frame(minHeight: Layout.webViewMinHeight)
        }
    }

    #if DEBUG
    var debugModalTriggers: some View {
        VStack(spacing: 8) {
            Button("일정 모달") {
                store.send(.dayScheduleModalOpened(
                    dayTitle: CalendarDayScheduleFixture.dayTitle,
                    items: CalendarDayScheduleFixture.listItems
                ))
            }
            Button("엠티 모달") {
                store.send(.dayScheduleModalOpened(
                    dayTitle: CalendarDayScheduleFixture.dayTitle,
                    items: []
                ))
            }
        }
        .notosans(.caption1Bold)
        .padding(12)
        .background(Color.livithColor(.black80))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(16)
    }
    #endif
}

// MARK: - Computed Properties

private extension CalendarHomeContentView {
    var selectionBlockedToastBinding: Binding<Bool> {
        Binding(
            get: { showSelectionBlockedToast && !store.state.selectionBlockedToastMessage.isEmpty },
            set: { isPresented in
                if !isPresented {
                    dismissSelectionBlockedToast()
                }
            }
        )
    }

    var dayScheduleModalBinding: Binding<Bool> {
        Binding(
            get: { store.state.isDayScheduleModalPresented },
            set: { isPresented in
                if !isPresented {
                    store.send(.dayScheduleModalDismissed)
                }
            }
        )
    }
}

// MARK: - Actions

private extension CalendarHomeContentView {
    func dismissSelectionBlockedToast() {
        guard showSelectionBlockedToast || !store.state.selectionBlockedToastMessage.isEmpty else { return }

        showSelectionBlockedToast = false
        store.send(.onSelectionBlockedToastDisappear)
    }
}

// MARK: - Layout

private extension CalendarHomeContentView {
    enum Layout {
        static let webViewMinHeight: CGFloat = 500
    }
}
