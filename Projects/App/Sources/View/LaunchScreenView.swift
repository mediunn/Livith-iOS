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
            
            VStack(spacing: 0) {
                Spacer()
                
                Image.livithImage(.livithLogo)
                    .resizable()
                    .aspectRatio(204/52, contentMode: .fit)
                    .frame(height: 44)
                    .padding(.bottom, 24)
                
                Text("분산되어 있는 내한 정보를 한번에")
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.black50))
                    
                Spacer()
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
