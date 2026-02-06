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
    @Environment(\.homeCoordinator) private var coordinator
    
    @StateObject private var store: PreferenceUpdateStore
    
    @State private var isUpdateFailureModalPresented: Bool = false
    
    init(selectedGenreList: [PreferredGenre]) {
        self._store = StateObject(wrappedValue: PreferenceUpdateStore(selectedGenreList))
    }
    
    var body: some View {
        ArtistEditView(config: .home(), isSubmitting: store.state.isLoading) {
            self.coordinator?.pop()
        } onSkip: {
            store.send(.onSkip)
        } onSubmit: { artistList in
            store.send(.onSubmit(artistList))
        }
        .onChange(of: store.state.result) { _, result in
            switch result {
            case .success:
                self.coordinator?.popToRoot()
            case .failure:
                isUpdateFailureModalPresented = true
            case .idle:
                break
            }
        }
        .crossDissolve(isPresented: $isUpdateFailureModalPresented, dismissOnTapOutside: false) {
            LivithModal(
                type: .error(title: "오류가 발생했어요!", message: "홈에서 다시 시도해주세요"),
                confirmTitle: "홈으로 돌아가기",
                onConfirm: {
                    isUpdateFailureModalPresented = false
                    coordinator?.popToRoot()
                }
            )
        }
    }
}
