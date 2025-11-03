//
//  StatusChip.swift
//  Search
//
//  Created by Youjin Lee on 11/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DesignSystem
import SearchDomain

public struct StatusChip: View {
    
    // MARK: - Property
    
    private let status: SearchDomain.ConcertStatus
    private let remainDays: Int
    
    private var statusText: String { getStatusText(status: status) }
    
    // MARK: - LifeCycle
    
    init(status: SearchDomain.ConcertStatus, remainDays: Int = 0) {
        self.status = status
        self.remainDays = remainDays
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack(alignment: .center) {
            Text(statusText)
                .notosans(.caption1Bold)
                .foregroundStyle(Color.livithColor(.black30))
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 7)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Helper Method

private extension StatusChip {
    func getStatusText(status: SearchDomain.ConcertStatus) -> String {
        switch status {
        case .completed:
            return "종료"
        case .ongoing:
            return "진행중"
        case .upcoming:
            return "D-\(remainDays)"
        case .canceled:
            return "공연취소"
        }
    }
}
