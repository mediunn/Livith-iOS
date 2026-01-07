//
//  LaunchScreenView.swift
//  Livith-iOS
//
//  Created by 김진웅 on 12/13/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Image.livithImage(.splash)
                .resizable()
                .ignoresSafeArea()
            
            Image.livithImage(.livithLogo)
                .resizable()
                .aspectRatio(204/52, contentMode: .fit)
                .frame(height: 48)
                .padding(.bottom, 24)
        }
    }
}

#Preview {
    LaunchScreenView()
}
