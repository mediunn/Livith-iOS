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
import Alamofire

struct HomeErrorMapper {
    func mapToDomainError(from error: Error) -> HomeError {
        guard let networkError = error as? NetworkError else { return .unknown }

        switch networkError {
        case .noConnection:
            return .noConnection
        case .serverError:
            return .serverError
        case .decodingFailed:
            return .noResponse
        case .unknown(let error):
            if let afError = error as? AFError, case .explicitlyCancelled = afError {
                return .cancelled
            }
            return .unknown
        default:
            return .unknown
        }
    }
}
