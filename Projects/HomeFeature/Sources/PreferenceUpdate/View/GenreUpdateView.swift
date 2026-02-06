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
import Coordinator

struct GenreUpdateView: View {
    @Environment(\.homeCoordinator) private var coordinator
    var body: some View {
        GenreEditView(mode: .home()) {
            self.coordinator?.pop()
        } onSubmit: { genreList in
            
            // TODO: 다음 화면으로 전달
            
        }
    }
}
