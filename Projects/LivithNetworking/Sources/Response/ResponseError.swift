//
//  ResponseError.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum ResponseError: Error {
    case invalidStatusCode(Int, message: String?)
    case noData
    case decodingFailed(Error)
}
