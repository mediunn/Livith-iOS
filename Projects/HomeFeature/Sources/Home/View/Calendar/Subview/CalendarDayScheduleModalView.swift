//
//  CalendarDayScheduleModalView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct CalendarDayScheduleModalView: View {

    // MARK: - Properties

    let dayTitle: String
    let itemList: [CalendarDayScheduleItem]
    let onDismiss: () -> Void
    let onInterestSettingTap: () -> Void

    // MARK: - Body

    var body: some View {
        modalCard
            .containerRelativeFrame(.vertical) { length, _ in
                length * Layout.heightRatio
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.horizontal, Layout.outerHorizontalPadding)
    }
}

// MARK: - UIComponents

private extension CalendarDayScheduleModalView {
    var modalCard: some View {
        VStack(spacing: .zero) {
            header
                .padding(.bottom, Layout.headerBottomSpacing)

            if itemList.isEmpty {
                emptyContent
            } else {
                scheduleList
            }
        }
        .padding(Layout.modalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: Layout.modalCornerRadius))
    }

    var header: some View {
        HStack(alignment: .top) {
            Text(dayTitle)
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Spacer(minLength: .zero)

            Button(action: onDismiss) {
                Image.livithIcon(.closeLineSmall)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Layout.closeIconSize, height: Layout.closeIconSize)
            }
            .buttonStyle(.plain)
        }
    }

    var scheduleList: some View {
        ScrollView {
            LazyVStack(spacing: Layout.listSpacing) {
                ForEach(itemList) { item in
                    CalendarDayScheduleItemRow(item: item)
                }
            }
        }
        .scrollIndicators(.visible)
    }

    var emptyContent: some View {
        VStack(spacing: Layout.emptyContentSpacing) {
            Spacer(minLength: .zero)

            LivithEmptyView(text: Constants.emptyMessage)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onInterestSettingTap) {
                Text(Constants.interestSettingTitle)
                    .notosans(.body4Medium)
                    .foregroundStyle(Color.livithColor(.black30))
                    .padding(.horizontal, Layout.ctaHorizontalPadding)
                    .padding(.vertical, Layout.ctaVerticalPadding)
                    .overlay {
                        RoundedRectangle(cornerRadius: Layout.ctaCornerRadius)
                            .strokeBorder(Color.livithColor(.black50), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)

            Spacer(minLength: .zero)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Constants

private extension CalendarDayScheduleModalView {
    enum Constants {
        static let emptyMessage = "공연 일정이 없어요"
        static let interestSettingTitle = "관심 콘서트 설정하기"
    }
}

// MARK: - Layout

private extension CalendarDayScheduleModalView {
    enum Layout {
        static let heightRatio: CGFloat = 540 / 812
        static let modalPadding: CGFloat = 16
        static let modalCornerRadius: CGFloat = 16
        static let outerHorizontalPadding: CGFloat = 16
        static let headerBottomSpacing: CGFloat = 20
        static let closeIconSize: CGFloat = 24
        static let listSpacing: CGFloat = 16
        static let emptyContentSpacing: CGFloat = 20
        static let ctaHorizontalPadding: CGFloat = 12
        static let ctaVerticalPadding: CGFloat = 10
        static let ctaCornerRadius: CGFloat = 8
    }
}
