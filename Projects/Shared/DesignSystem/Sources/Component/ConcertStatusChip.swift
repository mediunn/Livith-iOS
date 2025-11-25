//
//  ConcertStatusChip.swift
//  DesignSystem
//
//  Created by Youjin Lee on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct ConcertStatusChip: View {
    
    // MARK: - Property
    
    private let remainDays: Int
    private let statusText: String
    
    // MARK: - LifeCycle
    
    public init(statusText: String, remainDays: Int = 0) {
        self.statusText = statusText
        self.remainDays = remainDays
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack(alignment: .center) {
            buttonText
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 7)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

private extension ConcertStatusChip {
    var buttonText: some View {
        Text(remainDays == 0 ? statusText : "\(statusText)\(remainDays)")
            .notosans(.caption1Bold)
            .foregroundStyle(Color.livithColor(.black30))
    }
}

#Preview {
    ConcertStatusChip(statusText: "D-", remainDays: 3)
}
