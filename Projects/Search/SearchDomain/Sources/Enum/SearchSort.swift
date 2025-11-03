//
//  SearchSort.swift
//  search
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum SearchSort: String {
    case latest
    case alphabetical
}

public extension SearchSort {
    var rawValue: String {
        switch self {
        case .latest:
            return "LATEST"
        case .alphabetical:
            return "ALPHABETICAL"
        }
    }
}
