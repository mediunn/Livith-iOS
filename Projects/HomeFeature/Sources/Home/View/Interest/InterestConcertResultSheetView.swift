//
//  InterestConcertResultSheetView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/17/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct InterestConcertResultSheetView: View {

    // MARK: - Properties

    let content: InterestConcertResultSheetContent
    @Binding var sheetHeight: CGFloat
    let onConfirm: () -> Void
    let onCheckTap: (Int) -> Void
    let onRetryTap: () -> Void

    @State private var scrollContentHeight: CGFloat = 0

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            ScrollView {
                scrollContent
                    .background {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: InterestConcertResultSheetScrollHeightKey.self,
                                value: proxy.size.height
                            )
                        }
                    }
            }
            .scrollIndicators(.hidden)
            .frame(height: scrollViewportHeight)

            confirmButton
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.top, Constants.buttonTopPadding)
                .padding(.bottom, Constants.buttonBottomPadding)
        }
        .frame(maxWidth: .infinity)
        .background(Color.livithColor(.black90))
        .onPreferenceChange(InterestConcertResultSheetScrollHeightKey.self) { height in
            updateMeasuredHeight(scrollContentHeight: height)
        }
    }
}

// MARK: - Computed Properties

private extension InterestConcertResultSheetView {
    var buttonSectionHeight: CGFloat {
        Constants.buttonTopPadding
            + Constants.confirmButtonHeight
            + Constants.buttonBottomPadding
    }

    /// 스크롤 영역 높이. 시트가 max에 걸리면 남는 높이만 쓰고, 아니면 콘텐츠 높이 그대로.
    var scrollViewportHeight: CGFloat {
        let maxScrollHeight = Constants.maxSheetHeight - buttonSectionHeight
        guard scrollContentHeight > 0 else {
            return maxScrollHeight
        }
        return min(scrollContentHeight, maxScrollHeight)
    }
}

// MARK: - UIComponents

private extension InterestConcertResultSheetView {
    var scrollContent: some View {
        VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
            titleSection

            if !content.autoCleanupItemList.isEmpty {
                autoCleanupSection
            }

            if !content.requestResultItemList.isEmpty {
                requestResultSection
            }
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.top, Constants.contentTopPadding)
        .padding(.bottom, Constants.contentBottomPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var titleSection: some View {
        VStack(alignment: .leading, spacing: Constants.titleLineSpacing) {
            Text(Literals.titleLine1)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Text(Literals.titleLine2)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var autoCleanupSection: some View {
        VStack(alignment: .leading, spacing: Constants.sectionHeaderSpacing) {
            Text(Literals.autoCleanupSectionTitle)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.black5))

            VStack(spacing: Constants.cardSpacing) {
                ForEach(content.autoCleanupItemList) { item in
                    autoCleanupCard(item)
                }
            }
        }
    }

    var requestResultSection: some View {
        VStack(alignment: .leading, spacing: Constants.sectionHeaderSpacing) {
            Text(Literals.requestSectionTitle)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.black5))

            VStack(spacing: Constants.cardSpacing) {
                ForEach(content.requestResultItemList) { item in
                    requestResultCard(item)
                }
            }
        }
    }

    func autoCleanupCard(_ item: InterestConcertResultSheetContent.AutoCleanupItem) -> some View {
        VStack(alignment: .leading, spacing: Constants.autoCleanupCardTextSpacing) {
            Text(item.title)
                .notosans(.body3Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Text(item.description)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Constants.cardHorizontalPadding)
        .padding(.vertical, Constants.cardVerticalPadding)
        .background(Color.livithColor(.black80))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
    }

    func requestResultCard(_ item: InterestConcertResultSheetContent.RequestResultItem) -> some View {
        HStack(alignment: .top, spacing: Constants.cardInnerSpacing) {
            VStack(alignment: .leading, spacing: Constants.cardInnerSpacing) {
                statusBadge(isFailure: item.isFailure, title: item.badgeTitle)

                VStack(alignment: .leading, spacing: Constants.requestTextSpacing) {
                    Text(item.concertTitle)
                        .notosans(.body3Semibold)
                        .foregroundStyle(Color.livithColor(.white100))
                        .lineLimit(1)

                    Text(item.description)
                        .notosans(.body4Medium)
                        .foregroundStyle(Color.livithColor(.black50))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                switch item.outcome {
                case .added:
                    if let concertID = item.concertID {
                        onCheckTap(concertID)
                    }
                case .failed:
                    onRetryTap()
                }
            } label: {
                HStack(spacing: 0) {
                    Text(item.actionTitle)
                        .notosans(.caption1Bold)
                        .foregroundStyle(Color.livithColor(.black50))

                    Image.livithIcon(.rightLineDefault)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.livithColor(.black50))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, Constants.cardHorizontalPadding)
        .padding(.trailing, Constants.requestCardTrailingPadding)
        .padding(.vertical, Constants.requestCardVerticalPadding)
        .background(Color.livithColor(.black80))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
    }

    /// Figma: 추가 완료 = black100 + black5, 추가 실패 = translation + black80, capsule
    func statusBadge(isFailure: Bool, title: String) -> some View {
        Text(title)
            .notosans(.caption1Semibold)
            .foregroundStyle(isFailure ? Color.livithColor(.black80) : Color.livithColor(.black5))
            .padding(.horizontal, Constants.badgeHorizontalPadding)
            .padding(.vertical, Constants.badgeVerticalPadding)
            .background(isFailure ? Color.livithColor(.translation) : Color.livithColor(.black100))
            .clipShape(Capsule())
    }

    var confirmButton: some View {
        LivithButton(Literals.confirm, variant: .primary) {
            onConfirm()
        }
    }
}

// MARK: - Helpers

private extension InterestConcertResultSheetView {
    func updateMeasuredHeight(scrollContentHeight: CGFloat) {
        guard scrollContentHeight > 0 else { return }

        self.scrollContentHeight = scrollContentHeight

        let idealHeight = scrollContentHeight + buttonSectionHeight
        let resolvedHeight = min(
            max(idealHeight, Constants.minSheetHeight),
            Constants.maxSheetHeight
        )

        guard abs(sheetHeight - resolvedHeight) > 0.5 else { return }
        sheetHeight = resolvedHeight
    }
}

// MARK: - Constants

private extension InterestConcertResultSheetView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let contentTopPadding: CGFloat = 24
        static let contentBottomPadding: CGFloat = 16
        static let buttonTopPadding: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 24
        static let confirmButtonHeight: CGFloat = 52
        static let sectionSpacing: CGFloat = 20
        static let sectionHeaderSpacing: CGFloat = 16
        static let cardSpacing: CGFloat = 10
        static let cardInnerSpacing: CGFloat = 8
        static let autoCleanupCardTextSpacing: CGFloat = 4
        static let requestTextSpacing: CGFloat = 4
        static let cardHorizontalPadding: CGFloat = 20
        static let cardVerticalPadding: CGFloat = 20
        static let requestCardTrailingPadding: CGFloat = 10
        static let requestCardVerticalPadding: CGFloat = 16
        static let cardCornerRadius: CGFloat = 10
        static let badgeHorizontalPadding: CGFloat = 6
        static let badgeVerticalPadding: CGFloat = 4
        static let titleLineSpacing: CGFloat = 0
        /// Figma 최대 높이
        static let maxSheetHeight: CGFloat = 580
        /// 측정 전·콘텐츠 극소일 때 하한
        static let minSheetHeight: CGFloat = 200
    }

    enum Literals {
        static let titleLine1 = "관심 콘서트"
        static let titleLine2 = "소식이 도착했어요"
        static let autoCleanupSectionTitle = "자동 정리된 공연"
        static let requestSectionTitle = "요청한 공연"
        static let confirm = "확인"
    }
}

// MARK: - PreferenceKey

private struct InterestConcertResultSheetScrollHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
