//
//  PreferredGenreSettingView.swift
//  LoginFeature
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import PreferenceFeature
import LivithDesignSystem

struct PreferredGenreSettingView: View {
    @EnvironmentObject private var router: LoginRouter

    @State private var isDiscardChangesModalPresented: Bool = false
    
    private let session: SignupSession
    
    init(session: SignupSession) {
        self.session = session
    }
    
    var body: some View {
        GenreEditView(config: .genreOnboarding()) { isModified in
            if isModified {
                isDiscardChangesModalPresented = true
            } else {
                router.pop()
            }
        } onSubmit: { selectedGenreList in
            AmplitudeService.shared.trackEvent(tag: .confirm(.genrePreference))
            var updatedSession = session
            updatedSession.selectPreferredGenres(selectedGenreList)
            router.push(.preferredArtist(updatedSession))
        }
        .crossDissolve(isPresented: $isDiscardChangesModalPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: "선택된 아티스트나 장르가 해제돼요.\n이전 페이지로 돌아가시나요?",
                confirmTitle: "뒤로 갈게요",
                cancelTitle: "잘못 눌렀어요",
                type: .confirm(onConfirm: {
                    isDiscardChangesModalPresented = false
                    router.pop()
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
