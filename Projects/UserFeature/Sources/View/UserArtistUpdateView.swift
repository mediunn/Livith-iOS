//
//  UserArtistUpdateView.swift
//  UserFeature
//
//  Created by 김진웅 on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import Coordinator
import PreferenceFeature
import LivithDesignSystem

struct UserArtistUpdateView: View {
    @StateObject private var store = UserArtistUpdateStore()
    @State private var isDiscardChangesModalPresented: Bool = false
    @State private var isFailureToastPresented: Bool = false

    private let selectedArtistList: [PreferredArtist]
    
    @Environment(\.userCoordinator) private var coordinator
    
    init(
        selectedArtistList: [PreferredArtist]
    ) {
        self.selectedArtistList = selectedArtistList
    }
    
    var body: some View {
        ArtistEditView(
            config: .artistEdit(),
            selectedArtistList: selectedArtistList,
            isSubmitting: store.state.isLoading
        ) { isModified in
            AmplitudeService.shared.trackEvent(tag: .click(.backPreference))
            if isModified {
                isDiscardChangesModalPresented = true
            } else {
                coordinator?.pop()
            }
        } onSubmit: { artistList in
            AmplitudeService.shared.trackEvent(tag: .confirm(.changeArtistPreference))
            store.send(.onSubmit(artistList))
        }
        .crossDissolve(isPresented: $isDiscardChangesModalPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: "선택된 아티스트가 저장되지 않아요.\n이전 상태로 돌아가시나요?",
                confirmTitle: "뒤로 갈게요",
                cancelTitle: "잘못 눌렀어요",
                type: .confirm(onConfirm: {
                    AmplitudeService.shared.trackEvent(tag: .confirm(.backPreference))
                    isDiscardChangesModalPresented = false
                    coordinator?.pop()
                })
            ) {
                AmplitudeService.shared.trackEvent(tag: .click(.cancelPreference))
                isDiscardChangesModalPresented = false
            }
        }
        .livithToast(
            isPresented: $isFailureToastPresented,
            type: .failure,
            message: "아티스트 변경에 실패했어요"
        )
        .onChange(of: store.state.result) { _, result in
            switch result {
            case .success:
                coordinator?.onArtistUpdateSuccess?()
                coordinator?.pop()
            case .failure:
                isFailureToastPresented = true
            case .idle:
                break
            }
        }
    }
}
