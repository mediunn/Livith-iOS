//
//  ArtistEditView.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 2/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

public struct ArtistEditView: View {
    
    // MARK: - Properties
    
    @StateObject private var store: ArtistSelectionStore
    @State private var isSearchFocused: Bool = false
    
    private let config: ArtistEditConfig
    private let onBack: () -> Void
    private let onSkip: (() -> Void)?
    private let onSubmit: ([PreferredArtist]) -> Void
    
    public init(
        config: ArtistEditConfig,
        selectedArtists: [PreferredArtist] = [],
        onBack: @escaping () -> Void,
        onSkip: (() -> Void)? = nil,
        onSubmit: @escaping ([PreferredArtist]) -> Void
    ) {
        self._store = StateObject(wrappedValue: ArtistSelectionStore(selectedArtists: selectedArtists))
        self.config = config
        self.onBack = onBack
        self.onSkip = onSkip
        self.onSubmit = onSubmit
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: .zero) {
            navigationSection
            
            VStack(spacing: .zero) {
                stepIndicator
                    .padding(.top, Constants.indicatorTopPadding)
                
                titleSection
                    .padding(.top, Constants.titleTopPadding)
                
                ArtistSelectionView(
                    store: store,
                    isSearchFocused: $isSearchFocused
                )
                
                Spacer()
                
                submitButton
                    .padding(.bottom, Constants.bottomPadding)
            }
            .padding(.horizontal, Constants.horizontalPadding)
        }
        .background(.livithColor(.black100))
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .simultaneousGesture(TapGesture().onEnded { _ in
            isSearchFocused = false
        })
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Subviews

private extension ArtistEditView {
    var navigationSection: some View {
        if let onSkip {
            LivithNavigationView(
                type: .back(
                    title: config.navigationTitle,
                    onBack: onBack,
                    rightButtonTitle: "건너뛰기",
                    onRightButtonTap: onSkip
                )
            )
        } else {
            LivithNavigationView(
                type: .back(
                    title: config.navigationTitle,
                    onBack: onBack
                )
            )
        }
    }
    
    @ViewBuilder
    var stepIndicator: some View {
        if let stepInfo = config.stepIndicator {
            StepIndicatorView(
                currentStep: stepInfo.current,
                totalSteps: stepInfo.total
            )
        }
    }
    
    @ViewBuilder
    var titleSection: some View {
        if !isSearchFocused {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(config.title)
                        .notosans(.body1Semibold)
                        .foregroundStyle(Color.livithColor(.white100))
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = config.subtitle {
                        Text(subtitle)
                            .notosans(.body4Semibold)
                            .foregroundStyle(.livithColor(.black50))
                    }
                }
                
                Spacer()
                
                Text(selectedCountText)
                    .notosans(.body4Medium)
                    .foregroundStyle(Color.livithColor(.black50))
            }
        }
    }
    
    var submitButton: some View {
        LivithButton(config.submitTitle) {
            onSubmit(store.state.selectedArtistList)
        }
        .disabled(store.state.selectedArtistList.isEmpty)
    }
}

// MARK: - Helpers

private extension ArtistEditView {
    var selectedCountText: String {
        "\(store.state.selectedArtistList.count)/\(PreferenceSelectionRule.maxCount)"
    }
    
    var searchTextBinding: Binding<String> {
        Binding(
            get: { store.state.searchKeyword },
            set: { store.send(.search(keyword: $0)) }
        )
    }
    
    var exceedMaxSelectionToastBinding: Binding<Bool> {
        Binding(
            get: { store.state.isMaxSelectionToastPresented },
            set: { isPresented in
                guard !isPresented else { return }
                store.send(.resetMaxSelectionToast)
            }
        )
    }
}

// MARK: - Constants

private extension ArtistEditView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let titleTopPadding: CGFloat = 30
        static let indicatorTopPadding: CGFloat = 10
        static let bottomPadding: CGFloat = 16
    }
}

// MARK: - Preview

#Preview {
    ArtistEditView(
        config: .onboarding(),
        onBack: { print("뒤로가기 눌림") },
        onSkip: { print("건너뛰기 눌림") },
        onSubmit: { artists in
            print("\(artists) 제출")
        }
    )
}
