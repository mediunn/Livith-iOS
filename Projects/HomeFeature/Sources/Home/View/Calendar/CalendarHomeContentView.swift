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
    @State private var showDayScheduleLoadFailedToast = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: .zero) {
                    if showsFilterBar {
                        CalendarFilterBarView(store: store)
                    }

                    calendarBody
                }
            }
            .scrollIndicators(.never)
            .refreshable {
                await store.performRefresh()
            }
            .onAppear {
                store.send(.onAppear)
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
        .onChange(of: store.state.dayScheduleLoadFailedToastTrigger) { _, newValue in
            guard newValue > 0 else { return }
            showDayScheduleLoadFailedToast = true
        }
        .onDisappear {
            dismissSelectionBlockedToast()
            dismissDayScheduleLoadFailedToast()
        }
        .livithToast(
            isPresented: selectionBlockedToastBinding,
            type: .failure,
            message: store.state.selectionBlockedToastMessage
        )
        .livithToast(
            isPresented: dayScheduleLoadFailedToastBinding,
            type: .failure,
            message: store.state.dayScheduleLoadFailedToastMessage
        )
        .crossDissolve(isPresented: dayScheduleModalBinding, dismissOnTapOutside: true) {
            CalendarDayScheduleModalView(
                dayTitle: store.state.selectedDayTitle,
                eventList: store.state.dayScheduleEventList,
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
        if store.state.isInitialLoading {
            loadingView
        } else if store.state.isLoadFailed {
            LivithEmptyView(text: CalendarHomeStore.Constants.loadFailedEmptyMessage)
                .frame(maxWidth: .infinity)
                .containerRelativeFrame(.vertical)
        } else {
            CalendarWebView()
                .frame(minHeight: Layout.webViewMinHeight)
        }
    }

    var loadingView: some View {
        VStack(spacing: .zero) {
            Spacer(minLength: Layout.loadingMinHeight)

            ProgressView()
                .scaleEffect(1.6, anchor: .center)

            Spacer(minLength: Layout.loadingMinHeight)
        }
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical)
    }

    #if DEBUG
    var debugModalTriggers: some View {
        Button("일정 모달") {
            store.send(.dayScheduleRequested(date: Date()))
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
    var showsFilterBar: Bool {
        !store.state.isLoadFailed && !store.state.isInitialLoading
    }

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

    var dayScheduleLoadFailedToastBinding: Binding<Bool> {
        Binding(
            get: { showDayScheduleLoadFailedToast && !store.state.dayScheduleLoadFailedToastMessage.isEmpty },
            set: { isPresented in
                if !isPresented {
                    dismissDayScheduleLoadFailedToast()
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

    func dismissDayScheduleLoadFailedToast() {
        guard showDayScheduleLoadFailedToast || !store.state.dayScheduleLoadFailedToastMessage.isEmpty else { return }

        showDayScheduleLoadFailedToast = false
        store.send(.onDayScheduleLoadFailedToastDisappear)
    }
}

// MARK: - Layout

private extension CalendarHomeContentView {
    enum Layout {
        static let webViewMinHeight: CGFloat = 500
        static let loadingMinHeight: CGFloat = 200
    }
}
