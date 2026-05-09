//
//  NetworkError.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum NetworkError: Error {
    case requestBuildFailed(RequestBuildError)
    case transportFailed(Error)
    case invalidResponse
    case responseFailed(ResponseError)
}
