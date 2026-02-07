//
//  UserGenreUpdateView.swift
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

struct UserGenreUpdateView: View {
    @StateObject private var store = UserGenreUpdateStore()
    @State private var isDiscardChangesModalPresented: Bool = false
    @State private var isFailureToastPresented: Bool = false
    
    private let selectedGenreList: [PreferredGenre]
    private let onBack: () -> Void
    private let onComplete: () -> Void
    
    init(
        selectedGenreList: [PreferredGenre],
        onBack: @escaping () -> Void = {},
        onComplete: @escaping () -> Void = {}
    ) {
        self.selectedGenreList = selectedGenreList
        self.onBack = onBack
        self.onComplete = onComplete
    }
    
    var body: some View {
        GenreEditView(
            config: .genreEdit(),
            selectedGenreList: selectedGenreList,
            isSubmitting: store.state.isLoading
        ) { isModified in
            if isModified {
                isDiscardChangesModalPresented = true
            } else {
                onBack()
            }
        } onSubmit: { genreList in
            store.send(.onSubmit(genreList))
        }
        .crossDissolve(isPresented: $isDiscardChangesModalPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: "선택된 장르가 저장되지 않아요.\n이전 상태로 돌아가시나요?",
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
        .livithToast(
            isPresented: $isFailureToastPresented,
            type: .failure,
            message: "장르 변경에 실패했어요"
        )
    }
}
