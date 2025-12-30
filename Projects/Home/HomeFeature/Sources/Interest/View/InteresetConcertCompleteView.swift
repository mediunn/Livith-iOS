//
//  InteresetConcertCompleteView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeDomain

struct InteresetConcertCompleteView: View {
    @State private var isRotating = false
    
    var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .ignoresSafeArea()
            
            Image.livithImage(.interestConcertComplete)
                .scaledToFill()
                .rotationEffect(.degrees(isRotating ? 360 : 0), anchor: .center)
                .animation(.linear(duration: 5).repeatForever(autoreverses: false), value: isRotating)
            
            Rectangle()
                .fill(Color.livithColor(.yellow30))
                .frame(width: 130, height: 175, alignment: .center)
        }
        .onAppear {
            isRotating = true
        }
    }
}

#Preview {
    InteresetConcertCompleteView()
}
