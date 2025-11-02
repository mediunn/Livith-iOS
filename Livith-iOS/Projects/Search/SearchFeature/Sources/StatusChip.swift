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
    let status: SearchDomain.ConcertStatus
    
    init(status: SearchDomain.ConcertStatus) {
        self.status = status
    }
    
    public var body: some View {
        switch status {
        case .completed:
            Text("종료")
                .font(.notosans(.captionLarge))
        }
    }
}
