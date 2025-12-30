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
    private let isHighlighted: Bool
    
    // MARK: - LifeCycle
    
    public init(statusText: String, remainDays: Int = 0, isHighlighted: Bool = false) {
        self.statusText = statusText
        self.remainDays = remainDays
        self.isHighlighted = isHighlighted
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack(alignment: .center) {
            buttonText
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 7)
        .background(.livithColor(isHighlighted ? .yellow30 : .black90))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

private extension ConcertStatusChip {
    var buttonText: some View {
        Text(remainDays <= 0 ? statusText : "\(statusText)\(remainDays)")
            .notosans(.caption1Bold)
            .foregroundStyle(.livithColor(isHighlighted ? .black100 : .black30))
    }
}

#Preview {
    VStack {
        ConcertStatusChip(statusText: "D-", remainDays: 3)
        ConcertStatusChip(statusText: "D-", remainDays: 3, isHighlighted: true)
    }    
}
