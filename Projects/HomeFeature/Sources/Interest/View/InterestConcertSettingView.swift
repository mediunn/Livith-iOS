//
//  InterestConcertSettingView.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct InterestConcertSettingView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter
    @StateObject private var store: InterestConcertSettingStore
    @State private var showErrorToast: Bool = false
    @State private var showSuccessToast: Bool = false
    @State private var isDiscardChangesModalPresented: Bool = false

    // MARK: - Initializer

    init(mode: InterestConcertSettingMode) {
        _store = StateObject(
            wrappedValue: InterestConcertSettingStore(mode: mode)
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
        }
        .onChange(of: store.state.errorMessage) { _, errorMessage in
            if !errorMessage.isEmpty {
                showErrorToast = true
            }
        }
        .onChange(of: store.state.successMessage) { _, successMessage in
            if !successMessage.isEmpty {
                showSuccessToast = true
                Task { @MainActor in
                    await Task.yield()
                    homeRouter.popToRoot()
                }
            }
        }
    }
}

// MARK: - UIComponents

private extension InterestConcertSettingView {
    var topSection: some View {
        VStack(spacing: .zero) {
            if !store.state.isSearchFocused {
                guideSection
            }

            searchTextField
                .padding(.top, store.state.isSearchFocused ? 12 : 30)
                .padding(.horizontal, Constants.horizontalPadding)
        }
    }

    var gridSection: some View {
        Group {
            if store.state.isInitialLoading || store.state.isSearchLoading {
                loadingView
            } else {
                InterestConcertSelectionGridView(
                    concertList: store.state.displayedConcertList,
                    selectedConcertIDList: store.state.selectedConcertIDList,
                    isLoadingMore: store.state.isLoadingMore,
                    onConcertTap: { store.send(.toggleConcertSelection($0)) },
                    onScroll: { store.send(.setSearchFocused(false)) },
                    onLoadMore: { store.send(.loadNextPage) }
                )
            }
        }
        .padding(.top, 12)
    }

    var bottomSection: some View {
        InterestConcertSelectionBottomSectionView(
            selectedConcertList: store.state.selectedConcertList,
            ctaTitle: store.state.mode.ctaTitle,
            isCTAEnabled: store.state.isCTAEnabled,
            isSubmitting: store.state.isSubmitting,
            onRemoveSelectedConcert: { store.send(.removeSelectedConcert($0)) },
            onSubmit: { store.send(.submit) }
        )
    }

    var navigationBar: some View {
        LivithNavigationView(
            type: .back(
                title: store.state.mode.navigationTitle,
                onBack: handleBackButtonTap
            )
        )
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
        .padding(.top, 30)
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
}

// MARK: - Helpers

private extension InterestConcertSettingView {
    var selectedCountText: String {
        "\(store.state.selectedConcertCount)개 선택"
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

    func handleBackButtonTap() {
        guard store.state.mode != .initialSetup else {
            homeRouter.pop()
            return
        }

        guard store.state.hasUnsavedChanges else {
            homeRouter.pop()
            return
        }

        isDiscardChangesModalPresented = true
    }
}

// MARK: - Constants

private extension InterestConcertSettingView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
    }

    enum Literals {
        static let guideTitle = "소식을 받을 콘서트를\n선택해 주세요"
        static let searchPlaceholder = "찾고 있는 콘서트나 가수를 검색하세요"
    }
}

// MARK: - Preview

#Preview("Initial Setup") {
    InterestConcertSettingView(
        mode: .initialSetup
    )
    .background(Color.livithColor(.black100))
}

#Preview("Update") {
    InterestConcertSettingView(
        mode: .update
    )
    .background(Color.livithColor(.black100))
}
