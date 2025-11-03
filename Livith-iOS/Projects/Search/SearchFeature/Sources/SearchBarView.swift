//
//  SearchBarView.swift
//  Search
//
//  Created by Youjin Lee on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DesignSystem

public struct SearchBarView: View {
    
    // MARK: Property
    
    @Binding var input: String
    
    // MARK: - Body
    
    public var body: some View {
        HStack(alignment: .center, spacing: 16) {
            backButton()
            searchBar()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - ViewBuilder

private extension SearchBarView {
    @ViewBuilder
    func backButton() -> some View {
        Button (action: {
            // TODO: 화면 전환 구현
        }) {
            Image.livithIcon(.backLineDefault)
                .resizable()
                .scaledToFit()
                .frame(width: 38, height: 38)
        }
    }
    
    @ViewBuilder
    func searchBar() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 52)
                .foregroundStyle(Color.livithColor(.black90))
            
            HStack(alignment: .center, spacing: 10) {
                searchTextField()
                    .padding(.leading, 12)
                
                searchButton()
                    .padding(.trailing, 12)
            }
        }
    }
    
    @ViewBuilder
    func searchTextField() -> some View {
        ZStack(alignment: .leading) {
            if input.isEmpty {
                Text("찾고 있는 콘서트나 가수를 검색하세요")
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.black50))
            }
            
            TextField("", text: $input)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.white100))
        }
    }
    
    @ViewBuilder
    func searchButton() -> some View {
        Button (action: {
            // TODO: 화면 전환 구현
        }) {
            Image.livithIcon(.searchLineDefault)
                .resizable()
                .scaledToFit()
                .frame(width: 38, height: 38)
        }
    }
}
