//
//  InstagramMatchConfirmView.swift
//  HomeFeature
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import DisplaySupport
import LivithDesignSystem

struct InstagramMatchConfirmView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter
    @StateObject private var store: InstagramMatchConfirmStore
    @State private var showErrorToast: Bool = false
    @State private var showSuccessToast: Bool = false

    // MARK: - Initializer

    init(sourceURL: URL) {
        _store = StateObject(
            wrappedValue: InstagramMatchConfirmStore(sourceURL: sourceURL)
        )
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: .zero) {
                topSection

                contentSection

                searchDirectlyButton
                    .padding(.top, 30)

                Spacer()
            }

            bottomSection
        }
        .background(Color.livithColor(.black100))
        .navigationBarHidden(true)
        .livithToast(
            isPresented: Binding(
                get: { showErrorToast && !store.state.errorMessage.isEmpty },
                set: { if !$0 { showErrorToast = false; store.send(.clearErrorMessage) } }
            ),
            type: .failure,
            message: store.state.errorMessage
        )
        .livithToast(
            isPresented: Binding(
                get: { showSuccessToast && !store.state.successMessage.isEmpty },
                set: { if !$0 { showSuccessToast = false; store.send(.clearSuccessMessage) } }
            ),
            type: .success,
            message: store.state.successMessage
        )
        .crossDissolve(isPresented: cancelModalPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: Literals.cancelModalMessage,
                confirmTitle: Literals.cancelModalConfirmTitle,
                cancelTitle: Literals.cancelModalCancelTitle,
                type: .confirm(onConfirm: { store.send(.confirmCancel) }),
                onCancel: { store.send(.dismissCancelModal) }
            )
        }
        .onChange(of: store.state.errorMessage) { _, errorMessage in
            if !errorMessage.isEmpty {
                showErrorToast = true
            }
        }
        .onChange(of: store.state.successMessage) { _, successMessage in
            if !successMessage.isEmpty {
                showSuccessToast = true
            }
        }
        .onChange(of: store.state.shouldNavigateToHome) { _, shouldNavigate in
            if shouldNavigate {
                Task { @MainActor in
                    await Task.yield()
                    homeRouter.popToRoot()
                }
            }
        }
        .onChange(of: store.state.shouldNavigateToSearch) { _, shouldNavigate in
            if shouldNavigate {
                homeRouter.pop()
                homeRouter.push(.instagramMatchSearch(context: .matchFailed))
            }
        }
    }
}

// MARK: - UIComponents

private extension InstagramMatchConfirmView {
    var topSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(guideTitle)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .multilineTextAlignment(.leading)

            Text(Literals.guideSubtitle)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 70)
        .padding(.horizontal, Constants.horizontalPadding)
    }

    var contentSection: some View {
        Group {
            if store.state.isExtracting {
                loadingDots
                    .frame(height: Constants.cardSectionHeight)
            } else {
                matchedConcertCards
            }
        }
        .padding(.top, 20)
    }

    var matchedConcertCards: some View {
        HStack(alignment: .top, spacing: Constants.cardSpacing) {
            ForEach(store.state.matchedConcertList) { concert in
                LivithCard(
                    imageURL: concert.posterURL,
                    title: ConcertDisplayHelper.title(for: concert),
                    subtitle: ConcertDisplayHelper.dateRange(for: concert),
                    secondaryText: concert.artist,
                    badge: .status(
                        text: ConcertDisplayHelper.statusBadge(for: concert),
                        remainDays: concert.daysLeft
                    ),
                    isSelected: store.state.selectedConcertID == concert.id,
                    isFlexible: true,
                    onTap: { store.send(.selectConcert(concert.id)) }
                )
            }

            // 매칭이 3개 미만이어도 카드 폭은 3열 기준을 유지한다 (빈 칸 균등 분할)
            ForEach(store.state.matchedConcertList.count..<Constants.maxCardCount, id: \.self) { _ in
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: 0)
            }
        }
        .padding(.horizontal, Constants.horizontalPadding)
    }

    var searchDirectlyButton: some View {
        Button {
            homeRouter.push(.instagramMatchSearch(context: .manualSearch))
        } label: {
            VStack(spacing: 6) {
                Text(Literals.searchDirectlyTitle)
                    .notosans(.body2Medium)
                    .foregroundStyle(Color.livithColor(.black50))

                Rectangle()
                    .fill(Color.livithColor(.black50))
                    .frame(height: 1)
            }
            .padding(8)
            .fixedSize()
        }
    }

    var bottomSection: some View {
        HStack(spacing: 15) {
            LivithButton(Literals.cancelTitle, variant: .cancel) {
                store.send(.cancelTapped)
            }

            LivithButton(
                Literals.registerTitle,
                variant: .primary
            ) {
                store.send(.register)
            }
            .disabled(!store.state.isCTAEnabled)
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.bottom, 50)
    }

    var loadingDots: some View {
        TimelineView(.animation) { context in
            let elapsedMs = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: Constants.dotCycleSeconds) * 1000

            HStack(spacing: 12) {
                ForEach(Array(Constants.dotTimelineList.enumerated()), id: \.offset) { _, timeline in
                    Circle()
                        .fill(Color.livithColor(.black50))
                        .frame(width: 8, height: 8)
                        .offset(y: timeline.offsetY(atMs: elapsedMs))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - DotTimeline

// Figma 모션 명세(2000ms 루프): 도트별로 -6pt 상승 → 홀드 → 복귀를 선형 보간으로 재생한다.
private struct DotTimeline {
    let riseStart: Double
    let riseEnd: Double
    let fallStart: Double
    let fallEnd: Double

    func offsetY(atMs time: Double) -> CGFloat {
        let peak: CGFloat = -6

        switch time {
        case riseStart..<riseEnd:
            return peak * CGFloat((time - riseStart) / (riseEnd - riseStart))
        case riseEnd..<fallStart:
            return peak
        case fallStart..<fallEnd:
            return peak * CGFloat(1 - (time - fallStart) / (fallEnd - fallStart))
        default:
            return 0
        }
    }
}

// MARK: - Helpers

private extension InstagramMatchConfirmView {
    var guideTitle: String {
        store.state.isExtracting ? Literals.extractingTitle : Literals.confirmTitle
    }

    var cancelModalPresented: Binding<Bool> {
        Binding(
            get: { store.state.isCancelModalPresented },
            set: { if !$0 { store.send(.dismissCancelModal) } }
        )
    }
}

// MARK: - Constants

private extension InstagramMatchConfirmView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 10
        static let cardSectionHeight: CGFloat = 262
        static let maxCardCount = 3
        static let dotCycleSeconds: Double = 2.0
        static let dotTimelineList: [DotTimeline] = [
            DotTimeline(riseStart: 0, riseEnd: 204, fallStart: 396, fallEnd: 603),
            DotTimeline(riseStart: 202, riseEnd: 400, fallStart: 600, fallEnd: 803),
            DotTimeline(riseStart: 395, riseEnd: 601, fallStart: 803, fallEnd: 995)
        ]
    }

    enum Literals {
        static let extractingTitle = "정보 추출 중입니다\n조금만 기다려 주세요"
        static let confirmTitle = "해당 공연이 맞다면,\n관심 콘서트에 등록할까요?"
        static let guideSubtitle = "관심 콘서트로 등록하면 예매 알림,\n콘서트 정보 업데이트 소식을 빠르게 받아볼 수 있어요!"
        static let searchDirectlyTitle = "직접 찾아볼게요"
        static let cancelTitle = "취소"
        static let registerTitle = "등록하기"
        static let cancelModalMessage = "관심 콘서트 등록을 그만 두시나요?\n관심 콘서트에서 다시 지정할 수 있어요."
        static let cancelModalConfirmTitle = "지금은 그만할래요"
        static let cancelModalCancelTitle = "잘못 눌렀어요"
    }
}
