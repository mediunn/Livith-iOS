//
//  CalendarHomeContentView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/17/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DIContainer
import LivithDesignSystem

import Amplitude

struct CalendarHomeContentView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter
    @ObservedObject var store: CalendarHomeStore
    @Injected private var calendarWebConfig: CalendarWebConfig

    @State private var showSelectionBlockedToast = false
    @State private var showDayScheduleLoadFailedToast = false
    @State private var webViewContentHeight = CalendarWebContentHeightMeasurer.fallbackHeight

    // MARK: - Body

    var body: some View {
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
                },
                onEventTap: { event in
                    store.send(.dayScheduleModalDismissed)
                    homeRouter.push(.concertDetail(
                        concertID: event.concertID,
                        initialTab: .artistDetail,
                        initialSection: nil
                    ))
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
            ZStack {
                CalendarWebView(
                    url: calendarWebConfig.url,
                    calendarMonth: store.state.calendarMonth,
                    contentHeight: $webViewContentHeight,
                    onDateSelected: { date in
                        AmplitudeService.shared.trackEvent(tag: .click(.calendarDate))
                        store.send(.dayScheduleRequested(date: date))
                    },
                    onMonthChanged: { startDate, endDate in
                        trackCalendarMonthChangeIfNeeded(startDate: startDate, endDate: endDate)
                        store.send(.monthChanged(startDate: startDate, endDate: endDate))
                    }
                )
                .frame(height: webViewContentHeight)

                if store.state.isInitialLoading {
                    loadingView
                }
            }
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
}

// MARK: - Computed Properties

private extension CalendarHomeContentView {
    var showsFilterBar: Bool {
        !store.state.isLoadFailed && store.state.calendarMonth != nil
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
    func trackCalendarMonthChangeIfNeeded(startDate: String, endDate: String) {
        guard let previousStartDate = store.state.rangeStartDate,
              let previousEndDate = store.state.rangeEndDate,
              previousStartDate != startDate || previousEndDate != endDate
        else {
            return
        }

        AmplitudeService.shared.trackEvent(tag: .click(.calendarMonth))
    }

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
        static let loadingMinHeight: CGFloat = 200
    }
}
