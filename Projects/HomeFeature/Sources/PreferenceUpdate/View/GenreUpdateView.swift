//
//  GenreUpdateView.swift
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

struct GenreUpdateView: View {
    @Environment(\.homeCoordinator) private var coordinator
    @State private var isDiscardChangesModalPresented: Bool = false

    var body: some View {
        GenreEditView(config: .genreHome()) { isModified in
            if isModified {
                isDiscardChangesModalPresented = true
            } else {
                coordinator?.pop()
            }
        } onSubmit: { genreList in
            coordinator?.push(to: .preferredAritstUpdate(selectedGenreList: genreList))
        }
        .crossDissolve(isPresented: $isDiscardChangesModalPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: "선택된 아티스트나 장르가 해제돼요.\n이전 페이지로 돌아가시나요?",
                confirmTitle: "뒤로 갈게요",
                cancelTitle: "잘못 눌렀어요",
                type: .confirm(onConfirm: {
                    isDiscardChangesModalPresented = false
                    coordinator?.pop()
                }),
                onCancel: {
                    isDiscardChangesModalPresented = false
                }
            )
        }
    }
}
