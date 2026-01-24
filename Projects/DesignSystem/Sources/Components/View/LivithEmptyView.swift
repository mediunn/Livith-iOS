//
//  LivithEmptyView.swift
//  DesignSystem
//
//  Created by Youjin Lee on 11/6/25.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct LivithEmptyView: View {
    private let text: String
    
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
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.black80))
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    LivithEmptyView(text: "안녕하세요")
}
