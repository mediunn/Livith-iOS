//
//  InstagramManualSearchView.swift
//  HomeFeature
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct InstagramManualSearchView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter
    @StateObject private var store: InstagramManualSearchStore
    @State private var showErrorToast: Bool = false
    @State private var showSuccessToast: Bool = false

    // MARK: - Initializer

    init(context: InstagramManualSearchContext) {
        _store = StateObject(
            wrappedValue: InstagramManualSearchStore(context: context)
        )
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: .zero) {
                navigationBar

                topSection

                gridSection
            }

            bottomGradient

            bottomSection
        }
        .background(Color.livithColor(.black100))
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .simultaneousGesture(TapGesture().onEnded { _ in
            store.send(.setSearchFocused(false))
        })
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
    }
}

// MARK: - UIComponents

private extension InstagramManualSearchView {
    var navigationBar: some View {
        HStack(spacing: .zero) {
            if store.state.context == .manualSearch {
                Button(action: { homeRouter.pop() }) {
                    Image.livithIcon(.backLineDefault)
                        .resizable()
                        .frame(width: 36, height: 36)
                }
                .padding(.leading, 16)
            }

            Spacer()

            LivithReportButton(Literals.reportButtonTitle, variant: .info) {
                // TODO: FR-06 공연 정보 요청 페이지 연결 (후속 이슈)
            }
            .padding(.trailing, 16)
        }
        .frame(height: Constants.navigationBarHeight)
        .overlay(alignment: .bottomTrailing) {
            reportTooltip
                .offset(y: Constants.tooltipBottomOffset)
                .padding(.trailing, Constants.horizontalPadding)
        }
        .zIndex(1)
    }

    var reportTooltip: some View {
        VStack(alignment: .trailing, spacing: .zero) {
            TooltipArrowShape()
                .fill(Color.livithColor(.yellow30))
                .frame(width: Constants.tooltipArrowWidth, height: Constants.tooltipArrowHeight)
                .padding(.trailing, Constants.tooltipArrowTrailingPadding)

            Text(Literals.reportTooltipTitle)
                .notosans(.caption2Semibold)
                .foregroundStyle(Color.livithColor(.black90))
                .padding(.horizontal, 15)
                .frame(height: Constants.tooltipBubbleHeight)
                .background(Capsule().fill(Color.livithColor(.yellow30)))
        }
    }

    var topSection: some View {
        VStack(spacing: .zero) {
            guideSection

            searchTextField
                .padding(.top, 32)
                .padding(.horizontal, Constants.horizontalPadding)
        }
    }

    var guideSection: some View {
        HStack(alignment: .top, spacing: .zero) {
            Text(store.state.context.guideTitle)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, Constants.horizontalPadding)
    }

    var searchTextField: some View {
        LivithTextField(
            text: searchText,
            isFocused: searchFocus,
            type: .search,
            placeholder: Literals.searchPlaceholder,
            onClear: { store.send(.clearSearchText) }
        )
    }

    var gridSection: some View {
        Group {
            if store.state.isInitialLoading || store.state.isSearchLoading {
                loadingView
            } else {
                InterestConcertSelectionGridView(
                    concertList: store.state.displayedConcertList,
                    selectedConcertIDList: selectedConcertIDList,
                    isLoadingMore: store.state.isLoadingMore,
                    onConcertTap: { store.send(.selectConcert($0)) },
                    onScroll: { store.send(.setSearchFocused(false)) },
                    onLoadMore: { store.send(.loadNextPage) }
                )
            }
        }
        .padding(.top, 9)
    }

    var bottomGradient: some View {
        GeometryReader { proxy in
            // 디자인: 버튼 상단 50pt 위에서 시작해 화면 맨 아래에서만 완전 불투명해지는 선형 그라데이션
            LinearGradient(
                colors: [
                    Color.livithColor(.black100).opacity(0),
                    Color.livithColor(.black100)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Constants.bottomGradientHeight + proxy.safeAreaInsets.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, -proxy.safeAreaInsets.bottom)
        }
        .allowsHitTesting(false)
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

    var loadingView: some View {
        VStack(spacing: .zero) {
            Spacer()

            ProgressView()
                .tint(Color.livithColor(.white100))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - TooltipArrowShape

private struct TooltipArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        let apexRadius: CGFloat = 2.5

        return Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addArc(
                tangent1End: CGPoint(x: rect.midX, y: rect.minY),
                tangent2End: CGPoint(x: rect.maxX, y: rect.maxY),
                radius: apexRadius
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

// MARK: - Helpers

private extension InstagramManualSearchView {
    var selectedConcertIDList: [Int] {
        guard let selectedConcertID = store.state.selectedConcertID else { return [] }

        return [selectedConcertID]
    }

    var searchText: Binding<String> {
        Binding(
            get: { store.state.searchText },
            set: { store.send(.updateSearchText($0)) }
        )
    }

    var searchFocus: Binding<Bool> {
        Binding(
            get: { store.state.isSearchFocused },
            set: { store.send(.setSearchFocused($0)) }
        )
    }

    var cancelModalPresented: Binding<Bool> {
        Binding(
            get: { store.state.isCancelModalPresented },
            set: { if !$0 { store.send(.dismissCancelModal) } }
        )
    }
}

// MARK: - Constants

private extension InstagramManualSearchView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let navigationBarHeight: CGFloat = 66
        static let tooltipArrowWidth: CGFloat = 13
        static let tooltipArrowHeight: CGFloat = 8
        static let tooltipArrowTrailingPadding: CGFloat = 18.5
        static let tooltipBubbleHeight: CGFloat = 21
        static let tooltipBottomOffset: CGFloat = 7
        static let bottomGradientHeight: CGFloat = 152
    }

    enum Literals {
        static let reportButtonTitle = "정보 요청"
        static let reportTooltipTitle = "찾는 콘서트가 없다면?"
        static let searchPlaceholder = "찾고 있는 콘서트나 가수를 검색하세요"
        static let cancelTitle = "취소"
        static let registerTitle = "등록하기"
        static let cancelModalMessage = "관심 콘서트 등록을 그만 두시나요?\n관심 콘서트에서 다시 지정할 수 있어요."
        static let cancelModalConfirmTitle = "지금은 그만할래요"
        static let cancelModalCancelTitle = "잘못 눌렀어요"
    }
}
