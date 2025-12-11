//
//  SearchErrorMapper.swift
//  SearchData
//
//  Created by Youjin Lee on 11/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import SearchDomain

public struct SearchErrorMapper {
    public init() { }
    
    func mapToSearchError(_ networkError: NetworkError) -> SearchError {
        switch networkError {
        case .noData:
            return .noSearchResult
        case .noConnection:
            return .networkError
        case .serverError:
            return .serverError
        case .decodingFailed, .invalidResponse:
            return .invalidResponse
        default:
            return .unknown
        }
    }
}
