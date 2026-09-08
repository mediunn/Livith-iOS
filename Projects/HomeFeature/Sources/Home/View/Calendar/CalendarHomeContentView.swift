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
    let scope: HomeScope<CalendarHomeState, CalendarHomeIntent>
    @Injected private var calendarWebConfig: CalendarWebConfig

    @State private var showSelectionBlockedToast = false
    @State private var showDayScheduleLoadFailedToast = false
    @State private var webViewContentHeight = CalendarWebContentHeightMeasurer.fallbackHeight

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                if showsFilterBar {
                    CalendarFilterBarView(scope: scope)
                }

                calendarBody
            }
        }
        .scrollIndicators(.never)
        .refreshable {
            await scope.send(.pullToRefresh).wait()
        }
        .onAppear {
            scope.send(.onAppear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
        .onChange(of: scope.state.selectionBlockedToastTrigger) { _, newValue in
            guard newValue > 0 else { return }
            showSelectionBlockedToast = true
        }
        .onChange(of: scope.state.dayScheduleLoadFailedToastTrigger) { _, newValue in
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
            message: scope.state.selectionBlockedToastMessage
        )
        .livithToast(
            isPresented: dayScheduleLoadFailedToastBinding,
            type: .failure,
            message: scope.state.dayScheduleLoadFailedToastMessage
        )
        .crossDissolve(isPresented: dayScheduleModalBinding, dismissOnTapOutside: true) {
            CalendarDayScheduleModalView(
                dayTitle: scope.state.selectedDayTitle,
                eventList: scope.state.dayScheduleEventList,
                onDismiss: { scope.send(.dayScheduleModalDismissed) },
                onInterestSettingTap: {
                    scope.send(.dayScheduleModalDismissed)
                    homeRouter.push(.interestConcertSetting(mode: .update))
                },
                onEventTap: { event in
                    scope.send(.dayScheduleModalDismissed)
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
        if scope.state.isLoadFailed {
            LivithEmptyView(text: CalendarHomeConstants.loadFailedEmptyMessage)
                .frame(maxWidth: .infinity)
                .containerRelativeFrame(.vertical)
        } else {
            ZStack {
                CalendarWebView(
                    url: calendarWebConfig.url,
                    calendarMonth: scope.state.calendarMonth,
                    contentHeight: $webViewContentHeight,
                    onDateSelected: { date in
                        AmplitudeService.shared.trackEvent(tag: .click(.calendarDate))
                        scope.send(.dayScheduleRequested(date: date))
                    },
                    onMonthChanged: { startDate, endDate in
                        trackCalendarMonthChangeIfNeeded(startDate: startDate, endDate: endDate)
                        scope.send(.monthChanged(startDate: startDate, endDate: endDate))
                    }
                )
                .frame(height: webViewContentHeight)

                if scope.state.isInitialLoading {
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
        !scope.state.isLoadFailed && scope.state.calendarMonth != nil
    }

    var selectionBlockedToastBinding: Binding<Bool> {
        Binding(
            get: { showSelectionBlockedToast && !scope.state.selectionBlockedToastMessage.isEmpty },
            set: { isPresented in
                if !isPresented {
                    dismissSelectionBlockedToast()
                }
            }
        )
    }

    var dayScheduleLoadFailedToastBinding: Binding<Bool> {
        Binding(
            get: { showDayScheduleLoadFailedToast && !scope.state.dayScheduleLoadFailedToastMessage.isEmpty },
            set: { isPresented in
                if !isPresented {
                    dismissDayScheduleLoadFailedToast()
                }
            }
        )
    }

    var dayScheduleModalBinding: Binding<Bool> {
        Binding(
            get: { scope.state.isDayScheduleModalPresented },
            set: { isPresented in
                if !isPresented {
                    scope.send(.dayScheduleModalDismissed)
                }
            }
        )
    }
}

// MARK: - Actions

private extension CalendarHomeContentView {
    func trackCalendarMonthChangeIfNeeded(startDate: String, endDate: String) {
        guard let previousStartDate = scope.state.rangeStartDate,
              let previousEndDate = scope.state.rangeEndDate,
              previousStartDate != startDate || previousEndDate != endDate
        else {
            return
        }

        AmplitudeService.shared.trackEvent(tag: .click(.calendarMonth))
    }

    func dismissSelectionBlockedToast() {
        guard showSelectionBlockedToast || !scope.state.selectionBlockedToastMessage.isEmpty else { return }

        showSelectionBlockedToast = false
        scope.send(.onSelectionBlockedToastDisappear)
    }

    func dismissDayScheduleLoadFailedToast() {
        guard showDayScheduleLoadFailedToast || !scope.state.dayScheduleLoadFailedToastMessage.isEmpty else { return }

        showDayScheduleLoadFailedToast = false
        scope.send(.onDayScheduleLoadFailedToastDisappear)
    }
}

// MARK: - Layout

private extension CalendarHomeContentView {
    enum Layout {
        static let loadingMinHeight: CGFloat = 200
    }
}
