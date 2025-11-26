//
//  ErrorSheetView.swift
//  DesignSystem
//
//  Created by Youjin Lee on 11/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct ErrorSheetView: View {
    private let title: String
    private let message: String
    
    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
    
    public var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.livithColor(.black100).opacity(90))
        }
    }
}
