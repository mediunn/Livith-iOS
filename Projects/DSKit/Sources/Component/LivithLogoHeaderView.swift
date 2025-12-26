//
//  LivithLogoHeaderView.swift
//  DSKit
//
//  Created by 김진웅 on 12/24/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct LivithLogoHeaderView: View {
    public init() {}
    
    public var body: some View {
        HStack {
            Image.livithImage(.livithLogo)
                .resizable()
                .frame(width: 100, height: 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .padding(.leading, 16)
            
            Spacer()
        }
    }
}

#Preview {
    VStack {
        LivithLogoHeaderView()
            .background(Color.livithColor(.black100))
        
        LivithLogoHeaderView()
            .background(Color.livithColor(.black90))
    }
}
