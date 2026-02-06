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
        GenreEditView(config: .genreHome()) { _ in
            coordinator?.pop()
        } onSubmit: { genreList in
            coordinator?.push(to: .preferredAritstUpdate(selectedGenreList: genreList))
        }
    }
}
