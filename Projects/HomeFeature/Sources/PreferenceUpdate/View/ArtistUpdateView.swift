//
//  ArtistUpdateView.swift
//  HomeFeature
//
//  Created by 김진웅 on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import PreferenceFeature
import LivithDesignSystem
import Coordinator

struct ArtistUpdateView: View {
    @EnvironmentObject private var homeRouter: HomeRouter

    @StateObject private var store: PreferenceUpdateStore

    @State private var isUpdateFailureModalPresented: Bool = false
    @State private var isDiscardChangesModalPresented: Bool = false
    @State private var isSuccessToastPresented: Bool = false

    init(selectedGenreList: [PreferredGenre]) {
        self._store = StateObject(wrappedValue: PreferenceUpdateStore(selectedGenreList))
    }

    var body: some View {
        ArtistEditView(config: .artistHome(), isSubmitting: store.state.isLoading) { isModified in
            if isModified {
                isDiscardChangesModalPresented = true
            } else {
                self.homeRouter.pop()
            }
        } onSkip: {
            store.send(.onSkip)
        } onSubmit: { artistList in
            store.send(.onSubmit(artistList))
        }
        .onChange(of: store.state.result) { _, result in
            switch result {
            case .success:
                isSuccessToastPresented = true
                homeRouter.popToRoot()
            case .failure:
                isUpdateFailureModalPresented = true
            case .idle:
                break
            }
        }
        .livithToast(
            isPresented: $isSuccessToastPresented,
            type: .success,
            message: "선호하는 음악 취향을 반영했어요"
        )
        .crossDissolve(isPresented: $isUpdateFailureModalPresented, dismissOnTapOutside: false) {
            LivithModal(
                type: .error(title: "오류가 발생했어요!", message: "홈에서 다시 시도해주세요"),
                confirmTitle: "홈으로 돌아가기",
                onConfirm: {
                    isUpdateFailureModalPresented = false
                    homeRouter.popToRoot()
                }
            )
        }
        .crossDissolve(isPresented: $isDiscardChangesModalPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: "선택된 아티스트나 장르가 해제돼요.\n이전 페이지로 돌아가시나요?",
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
    }
}
