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
    
    @Environment(\.userCoordinator) private var coordinator
    
    init(
        selectedGenreList: [PreferredGenre]
    ) {
        self.selectedGenreList = selectedGenreList
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
                coordinator?.pop()
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
                    coordinator?.pop()
                })
            ) {
                isDiscardChangesModalPresented = false
            }
        }
        .onChange(of: store.state.result) { _, result in
            switch result {
            case .success:
                coordinator?.pop()
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
