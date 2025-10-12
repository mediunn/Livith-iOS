//
//  BaseResponse.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let statusCode: Int
    let message: String
    let data: T?
}
