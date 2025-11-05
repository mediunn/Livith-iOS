//
//  EmptyView.swift
//  DesignSystem
//
//  Created by Youjin Lee on 11/6/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct EmptyView: View {
    private var text: String
    
    public init(text: String) {
        self.text = text
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .center) {
            Image.livithImage(.livithEmpty)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 40)
            
            Text(text)
                .padding(.top, 16)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.black80))
        }
    }
}
