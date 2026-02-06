//
//  PreferredGenreSettingView.swift
//  LoginFeature
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import PreferenceFeature

struct PreferredGenreSettingView: View {
    @Environment(\.loginCoordinator) private var coordinator
    
    private let builder: SignupBuilder
    
    init(builder: SignupBuilder) {
        self.builder = builder
    }
    
    var body: some View {
        GenreEditView(config: .genreOnboarding()) { _ in
            coordinator?.pop()
        } onSubmit: { selectedGenreList in
            let updated = builder.withPreferredGenreList(selectedGenreList)
            coordinator?.push(to: .preferredArtist(updated))
        }
    }
}
