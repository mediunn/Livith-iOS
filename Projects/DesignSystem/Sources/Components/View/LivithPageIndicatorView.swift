//
//  LivithPageIndicatorView.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 12/20/25.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct LivithPageIndicatorView: View {
    private let currentPage: Int
    private let pageCount: Int
    
    public init(currentPage: Int, pageCount: Int) {
        self.currentPage = currentPage
        self.pageCount = pageCount
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                if index == currentPage {
                    Capsule()
                        .fill(Color.livithColor(.yellow30))
                        .frame(width: 28, height: 4)
                } else {
                    Circle()
                        .fill(Color.livithColor(.yellow30))
                        .frame(width: 4, height: 4)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LivithPageIndicatorView(currentPage: 0, pageCount: 5)
        LivithPageIndicatorView(currentPage: 2, pageCount: 5)
        LivithPageIndicatorView(currentPage: 4, pageCount: 5)
    }
    .padding()
    .background(Color.black)
}
