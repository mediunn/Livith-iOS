//
//  CalendarWebConfig.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct CalendarWebConfig: Sendable {
    public let url: URL?

    public init(url: URL?) {
        self.url = url
    }
}
