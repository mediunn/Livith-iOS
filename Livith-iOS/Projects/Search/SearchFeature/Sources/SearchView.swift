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
        
        SearchBarView(input: $searchText)
            .foregroundStyle(Color.livithColor(.black100))
        
        ConcertDetailCard(
            posterURL: URL(string: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF264490_250508_131406.jpg")!,
            title: "테디 스윔스 첫 단독 내한공연",
            date: "2025.11.01~11.02",
            artist: "유우리 (Yuuri)",
            status: "종료"
        )
        .foregroundStyle(Color.livithColor(.black100))
    }
}
