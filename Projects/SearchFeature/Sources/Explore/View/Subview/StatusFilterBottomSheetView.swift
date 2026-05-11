//
//  StatusFilterBottomSheetView.swift
//  SearchFeature
//
//  Created by Youjin Lee on 4/28/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import LivithDesignSystem

struct StatusFilterBottomSheetView: View {
    @Binding var selectedStatusList: [ConcertStatus]
    @Binding var showFilter: Bool

    @State private var tempStatusList: [ConcertStatus] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("기간")
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .padding(.horizontal, 16)
                .padding(.top, 24)

            statusOptions
                .padding(.horizontal, 16)
                .padding(.top, 20)

            setupButtons
                .padding(.top, 24)
                .padding(.horizontal, 16)
        }
        .onChange(of: showFilter) { _, isShowing in
            if isShowing {
                tempStatusList = selectedStatusList
            }
        }
    }
}

private extension StatusFilterBottomSheetView {
    var hasSelection: Bool {
        !tempStatusList.isEmpty
    }

    var selectableStatusList: [ConcertStatus] {
        ConcertStatus.allCases.filter { $0 != .past }
    }

    var statusOptions: some View {
        HStack(alignment: .center, spacing: 8) {
            LivithChipButton(
                "전체",
                style: tempStatusList.isEmpty ? .selected : .outline
            ) {
                tempStatusList = []
            }

            ForEach(selectableStatusList, id: \.self) { status in
                LivithChipButton(
                    status.filterText,
                    style: tempStatusList.contains(status) ? .selected : .outline
                ) {
                    toggleStatus(status)
                }
            }
        }
    }

    var setupButtons: some View {
        HStack(spacing: 12) {
            LivithButton("초기화", variant: .secondary) {
                AmplitudeService.shared.trackEvent(tag: .click(.resetFilter))
                tempStatusList = []
            }
            .disabled(!hasSelection)

            LivithButton("설정하기", variant: .primary) {
                AmplitudeService.shared.trackEvent(tag: .click(.applyFilter))
                trackFilterEvents()
                selectedStatusList = tempStatusList
                showFilter = false
            }
            .disabled(!hasSelection)
        }
    }

    func trackFilterEvents() {
        for status in tempStatusList {
            switch status {
            case .ongoing:
                AmplitudeService.shared.trackEvent(tag: .setFilter(.ongoing))
            case .upcoming:
                AmplitudeService.shared.trackEvent(tag: .setFilter(.upcoming))
            case .completed:
                AmplitudeService.shared.trackEvent(tag: .setFilter(.completed))
            case .past, .canceled:
                break
            }
        }
    }

    func toggleStatus(_ status: ConcertStatus) {
        if tempStatusList.contains(status) {
            tempStatusList.removeAll { $0 == status }
        } else {
            tempStatusList.append(status)
        }
    }
}
