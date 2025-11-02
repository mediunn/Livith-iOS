//
//  SearchView.swift
//  Search
//
//  Created by Youjin Lee on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import SearchDomain
import DesignSystem

public struct SearchView: View {
    
    // MARK: - Property
    
    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    
    @State private var selectedGenreList: [SearchDomain.ConcertGenre] = []
    @State private var selectedStatusList: [SearchDomain.ConcertStatus] = []
    @State private var selectedSort: SearchDomain.SearchSort = .latest
    
    @State private var errorMessage: String = ""
    
    // MARK: - Lifecycle
    
    public init() { }
    
    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            
        }
        .foregroundStyle(Color.livithColor(.black100))
    }
}
