//
//  HomeErrorMapper.swift
//  HomeData
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import HomeDomain
import LivithNetwork

struct HomeErrorMapper {
    func mapToDomainError(from error: Error) -> HomeError {
        guard let networkError = error as? NetworkError else { return .unknown }

        switch networkError {
        case .noConnection:
            return .noConnection
        case .serverError:
            return .serverError
        default:
            return .unknown
        }
    }
}
