//
//  ErrorResponse.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct ErrorResponse: Decodable {
    let statusCode: Int
    let message: String
    let error: String?
}
