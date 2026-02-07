//
//  UserArtistUpdateView.swift
//  UserFeature
//
//  Created by 김진웅 on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import Coordinator
import PreferenceFeature
import LivithDesignSystem

struct UserArtistUpdateView: View {
    @StateObject private var store = UserArtistUpdateStore()
    @State private var isDiscardChangesModalPresented: Bool = false
    @State private var isFailureToastPresented: Bool = false

    private let selectedArtistList: [PreferredArtist]
    private let onBack: () -> Void
    private let onComplete: () -> Void
    
    init(
        selectedArtistList: [PreferredArtist],
        onBack: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) {
        self.selectedArtistList = selectedArtistList
        self.onBack = onBack
        self.onComplete = onComplete
    }
    
    var body: some View {
        ArtistEditView(
            config: .artistEdit(),
            selectedArtistList: selectedArtistList,
            isSubmitting: store.state.isLoading
        ) { isModified in
            if isModified {
                isDiscardChangesModalPresented = true
            } else {
                onBack()
            }
        } onSubmit: { artistList in
            store.send(.onSubmit(artistList))
        }
        .crossDissolve(isPresented: $isDiscardChangesModalPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: "선택된 아티스트가 저장되지 않아요.\n이전 상태로 돌아가시나요?",
                confirmTitle: "뒤로 갈게요",
                cancelTitle: "잘못 눌렀어요",
                type: .confirm(onConfirm: {
                    isDiscardChangesModalPresented = false
                    onBack()
                })
            ) {
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
                onComplete()
            case .failure:
                isFailureToastPresented = true
            case .idle:
                break
            }
        }
    }
}
