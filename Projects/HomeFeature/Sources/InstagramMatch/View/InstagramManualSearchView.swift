//
//  InstagramManualSearchView.swift
//  HomeFeature
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import LivithDesignSystem

struct InstagramManualSearchView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter
    @State private var viewModel: InstagramManualSearchViewModel
    @State private var isSearchFocused = false
    @State private var isCancelModalPresented = false

    private let context: InstagramManualSearchContext
    private let onRegisterSuccess: () -> Void

    // MARK: - Initializer

    init(
        context: InstagramManualSearchContext,
        concertCatalogRepository: any ConcertCatalogRepository,
        searchRepository: any SearchRepository,
        interestConcertRepository: any InterestConcertRepository,
        onRegisterSuccess: @escaping () -> Void
    ) {
        self.context = context
        self.onRegisterSuccess = onRegisterSuccess
        _viewModel = State(initialValue: InstagramManualSearchViewModel(
            concertCatalogRepository: concertCatalogRepository,
            searchRepository: searchRepository,
            interestConcertRepository: interestConcertRepository
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: .zero) {
                navigationBar

                topSection

                gridSection
            }
            .padding(.horizontal, Constants.horizontalPadding)

            bottomGradient

            bottomSection
        }
        .background(Color.livithColor(.black100))
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .simultaneousGesture(TapGesture().onEnded { _ in
            isSearchFocused = false
        })
        .onAppear { Task { await viewModel.loadIfNeeded() } }
        .task(id: viewModel.searchRevision) { await viewModel.searchIfNeeded() }
        .livithToast(
            isPresented: $viewModel.isErrorToastPresented,
            type: .failure,
            message: viewModel.errorMessage
        )
        .onChange(of: viewModel.didRegister) { _, succeeded in
            if succeeded { onRegisterSuccess() }
        }
        .onChange(of: viewModel.isErrorToastPresented) { _, isPresented in
            if !isPresented { viewModel.presentPendingErrorIfNeeded() }
        }
        .crossDissolve(isPresented: $isCancelModalPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: Literals.cancelModalMessage,
                confirmTitle: Literals.cancelModalConfirmTitle,
                cancelTitle: Literals.cancelModalCancelTitle,
                type: .confirm(onConfirm: {
                    isCancelModalPresented = false
                    homeRouter.popToRoot()
                }),
                onCancel: { isCancelModalPresented = false }
            )
            .padding(.horizontal, 24)
            .livithModalLayout()
        }
    }
}

// MARK: - UIComponents

private extension InstagramManualSearchView {
    var navigationBar: some View {
        HStack(spacing: .zero) {
            if context == .manualSearch {
                Button(action: { homeRouter.pop() }) {
                    Image.livithIcon(.backLineDefault)
                        .resizable()
                        .frame(width: 36, height: 36)
                }
            }

            Spacer()

            LivithReportButton(Literals.reportButtonTitle, variant: .info) {
                AmplitudeService.shared.trackEvent(tag: .click(.concertRequest))
                homeRouter.push(.concertRequest)
            }
        }
        .frame(height: Constants.navigationBarHeight)
        .overlay(alignment: .bottomTrailing) {
            reportTooltip
                .offset(y: Constants.tooltipBottomOffset)
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
                .notosans(.caption1Semibold)
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
        }
    }

    var guideSection: some View {
        HStack(alignment: .top, spacing: .zero) {
            Text(context.guideTitle)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(.top, 20)
    }

    var searchTextField: some View {
        LivithTextField(
            text: $viewModel.searchText,
            isFocused: $isSearchFocused,
            type: .search,
            placeholder: Literals.searchPlaceholder,
            onClear: { isSearchFocused = true }
        )
    }

    var gridSection: some View {
        Group {
            if viewModel.isInitialLoading || viewModel.isSearchLoading {
                loadingView
            } else {
                InterestConcertSelectionGridView(
                    concertList: viewModel.displayedConcertList,
                    selectedConcertIDList: selectedConcertIDList,
                    isLoadingMore: viewModel.isLoadingMore,
                    onConcertTap: viewModel.toggleConcertSelection,
                    onScroll: { isSearchFocused = false },
                    onLoadMore: { Task { await viewModel.loadNextPage() } }
                )
                .contentMargins(.bottom, viewModel.displayedConcertList.isEmpty ? 0 : 210, for: .scrollContent)
            }
        }
        .padding(
            .top,
            viewModel.isInitialLoading || viewModel.isSearchLoading ? 9 : 29
        )
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
                isCancelModalPresented = true
            }

            LivithButton(
                Literals.registerTitle,
                variant: .primary
            ) {
                AmplitudeService.shared.trackEvent(tag: .click(.igSearchSuccess))
                Task { await viewModel.register() }
            }
            .disabled(!viewModel.canRegister)
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
        guard let selectedConcertID = viewModel.selectedConcertID else { return [] }

        return [selectedConcertID]
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
        static let tooltipBubbleHeight: CGFloat = 31
        static let tooltipBottomOffset: CGFloat = 28
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
