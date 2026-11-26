//
//  InterestConcertSettingView.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import LivithDesignSystem

struct InterestConcertSettingView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter
    @State private var viewModel: InterestConcertSettingViewModel
    private let onSaveSuccess: () -> Void
    @State private var isScreenVisible = false
    @State private var isDiscardChangesModalPresented: Bool = false
    @State private var hasOpenedConcertRequest: Bool = false

    // MARK: - Initializer

    init(
        mode: InterestConcertSettingMode,
        concertCatalogRepository: any ConcertCatalogRepository,
        searchRepository: any SearchRepository,
        interestConcertRepository: any InterestConcertRepository,
        onSaveSuccess: @escaping () -> Void
    ) {
        self.onSaveSuccess = onSaveSuccess
        _viewModel = State(
            initialValue: InterestConcertSettingViewModel(
                mode: mode,
                concertCatalogRepository: concertCatalogRepository,
                searchRepository: searchRepository,
                interestConcertRepository: interestConcertRepository
            )
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
            .padding(.horizontal, Constants.horizontalPadding)

            bottomSection
        }
        .background(Color.livithColor(.black100))
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .onAppear {
            isScreenVisible = true
            Task { await viewModel.loadIfNeeded() }
        }
        .onDisappear { isScreenVisible = false }
        .simultaneousGesture(TapGesture().onEnded { _ in
            viewModel.isSearchFocused = false
        })
        .livithToast(
            isPresented: $viewModel.isErrorToastPresented,
            type: .failure,
            message: viewModel.errorMessage
        )
        .onChange(of: viewModel.isErrorToastPresented) { _, isPresented in
            if !isPresented { viewModel.presentPendingErrorIfNeeded() }
        }
        .crossDissolve(isPresented: $isDiscardChangesModalPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: "선택된 콘서트가 해제돼요.\n이전 페이지로 돌아가시나요?",
                confirmTitle: "뒤로 갈게요",
                cancelTitle: "잘못 눌렀어요",
                type: .confirm(onConfirm: {
                    isDiscardChangesModalPresented = false
                    homeRouter.pop()
                }),
                onCancel: {
                    isDiscardChangesModalPresented = false
                }
            )
            .padding(.horizontal, 24)
            .livithModalLayout()
        }
    }
}

// MARK: - UIComponents

private extension InterestConcertSettingView {
    var topSection: some View {
        VStack(spacing: .zero) {
            if !viewModel.isSearchFocused {
                guideSection
            }

            searchTextField
                .padding(.top, viewModel.isSearchFocused ? 12 : Constants.guideToSearchSpacing)
        }
    }

    var gridSection: some View {
        Group {
            if viewModel.isInitialLoading || viewModel.isSearchLoading {
                loadingView
            } else {
                InterestConcertSelectionGridView(
                    concertList: viewModel.displayedConcertList,
                    selectedConcertIDList: viewModel.selectedConcertIDList,
                    isLoadingMore: viewModel.isLoadingMore,
                    onConcertTap: { viewModel.toggleConcertSelection($0) },
                    onScroll: { viewModel.isSearchFocused = false },
                    onLoadMore: { Task { await viewModel.loadNextPage() } }
                )
                .contentMargins(.bottom, viewModel.displayedConcertList.isEmpty ? 0 : 210, for: .scrollContent)
            }
        }
        .padding(
            .top,
            viewModel.isInitialLoading || viewModel.isSearchLoading ? 12 : 32
        )
    }

    var bottomSection: some View {
        InterestConcertSelectionBottomSectionView(
            selectedConcertList: viewModel.selectedConcertList,
            ctaTitle: viewModel.mode.ctaTitle,
            isCTAEnabled: viewModel.hasUnsavedChanges,
            isSubmitting: viewModel.isSubmitting,
            onRemoveSelectedConcert: { viewModel.removeSelectedConcert($0) },
            onSubmit: {
                if viewModel.mode == .initialSetup {
                    AmplitudeService.shared.trackEvent(tag: .confirm(.interestConcert))
                }
                Task {
                    if await viewModel.submit(), isScreenVisible {
                        onSaveSuccess()
                    }
                }
            }
        )
    }

    var navigationBar: some View {
        HStack(spacing: 4) {
            Button(action: handleBackButtonTap) {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(
                        width: Constants.navigationBackIconSize,
                        height: Constants.navigationBackIconSize
                    )
            }

            Text(viewModel.mode.navigationTitle)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(1)

            Spacer(minLength: .zero)

            LivithReportButton(Literals.reportButtonTitle, variant: .info) {
                hasOpenedConcertRequest = true
                AmplitudeService.shared.trackEvent(tag: .click(.concertRequest))
                homeRouter.push(.concertRequest)
            }
        }
        .padding(.top, Constants.navigationContentTopPadding)
        .frame(height: Constants.navigationBarHeight, alignment: .top)
        .overlay(alignment: .bottomTrailing) {
            if !hasOpenedConcertRequest {
                reportTooltip
                    .offset(y: Constants.tooltipBottomOffset)
            }
        }
        .zIndex(1)
    }

    var reportTooltip: some View {
        VStack(alignment: .trailing, spacing: Constants.tooltipArrowBubbleOverlap) {
            TooltipArrowShape()
                .fill(Color.livithColor(.yellow30))
                .frame(width: Constants.tooltipArrowWidth, height: Constants.tooltipArrowHeight)
                .padding(.trailing, Constants.tooltipArrowTrailingPadding)

            Text(Literals.reportTooltipTitle)
                .notosans(.caption1Bold)
                .foregroundStyle(Color.livithColor(.black80))
                .padding(.horizontal, 15)
                .frame(height: Constants.tooltipBubbleHeight)
                .background(Capsule().fill(Color.livithColor(.yellow30)))
        }
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

    var guideSection: some View {
        HStack(alignment: .top, spacing: .zero) {
            Text(Literals.guideTitle)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .multilineTextAlignment(.leading)

            Spacer()

            Text(selectedCountText)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
        }
        .padding(.top, Constants.guideSectionTopPadding)
    }

    var searchTextField: some View {
        LivithTextField(
            text: searchText,
            isFocused: searchFocus,
            type: .search,
            placeholder: Literals.searchPlaceholder,
            onClear: { viewModel.clearSearchText() }
        )
    }
}

// MARK: - Helpers

private extension InterestConcertSettingView {
    var selectedCountText: String {
        "\(viewModel.selectedConcertIDList.count)개 선택"
    }

    var searchText: Binding<String> {
        Binding(
            get: { viewModel.searchText },
            set: { viewModel.updateSearchText($0) }
        )
    }

    var searchFocus: Binding<Bool> {
        Binding(
            get: { viewModel.isSearchFocused },
            set: { viewModel.isSearchFocused = $0 }
        )
    }

    func handleBackButtonTap() {
        guard viewModel.mode != .initialSetup else {
            homeRouter.pop()
            return
        }

        guard viewModel.hasUnsavedChanges else {
            homeRouter.pop()
            return
        }

        isDiscardChangesModalPresented = true
    }
}

// MARK: - TooltipArrowShape

private struct TooltipArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

// MARK: - Constants

private extension InterestConcertSettingView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let navigationBarHeight: CGFloat = 66
        static let navigationContentTopPadding: CGFloat = 20
        static let navigationBackIconSize: CGFloat = 38
        static let guideSectionTopPadding: CGFloat = 20
        static let guideToSearchSpacing: CGFloat = 20
        static let tooltipArrowWidth: CGFloat = 14
        static let tooltipArrowHeight: CGFloat = 8
        static let tooltipArrowTrailingPadding: CGFloat = 15
        static let tooltipArrowBubbleOverlap: CGFloat = -2
        static let tooltipBubbleHeight: CGFloat = 31
        static let tooltipBottomOffset: CGFloat = 28
    }

    enum Literals {
        static let guideTitle = "소식을 받을 콘서트를\n선택해 주세요"
        static let searchPlaceholder = "찾고 있는 콘서트나 가수를 검색하세요"
        static let reportButtonTitle = "정보 요청"
        static let reportTooltipTitle = "찾는 콘서트가 없다면?"
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Initial Setup") {
    let preview = SettingPreviewRepository()
    return InterestConcertSettingView(
        mode: .initialSetup,
        concertCatalogRepository: preview,
        searchRepository: preview,
        interestConcertRepository: preview,
        onSaveSuccess: {}
    )
    .environmentObject(HomeRouter())
    .background(Color.livithColor(.black100))
}

#Preview("Update") {
    let preview = SettingPreviewRepository()
    return InterestConcertSettingView(
        mode: .update,
        concertCatalogRepository: preview,
        searchRepository: preview,
        interestConcertRepository: preview,
        onSaveSuccess: {}
    )
    .environmentObject(HomeRouter())
    .background(Color.livithColor(.black100))
}

private struct SettingPreviewRepository: ConcertCatalogRepository, SearchRepository, InterestConcertRepository {
    func fetchAllConcertList(startDate: Date?, concertID: Int?) async throws(ConcertError) -> [Concert] { [] }

    func fetchAllConcertList(after position: (any PagePosition)?, size: Int) async throws(ConcertError) -> ListResult<Concert> { ListResult(items: [], position: nil) }

    func fetchSearchConcertSectionList() async throws(ConcertError) -> [ConcertSection] { [] }

    func fetchBanners() async throws(SearchError) -> [Banner] { [] }

    func fetchFilterSearchResult(
        genre: [ConcertGenre],
        sort: SearchSort?,
        status: [ConcertStatus],
        keyword: String?,
        after position: (any PagePosition)?,
        size: Int?
    ) async throws(SearchError) -> ListResult<Concert> { ListResult(items: [], position: nil) }

    func fetchRecommendedSearchResult(keyword: String) async throws(SearchError) -> [String] { [] }

    func fetchInterestedConcertList(filter: InterestConcertListFilter) async throws(UserError) -> ListResult<InterestConcert> { ListResult(items: [], position: nil) }

    func checkInterestedConcert(id: Int) async throws(UserError) -> Bool { false }

    func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert { throw .serverError }

    func updateInterestedConcertList(_ concertIDList: [Int]) async throws(UserError) -> [Concert] { [] }

    func deleteInterestedConcert() async throws(UserError) {}
}
#endif
