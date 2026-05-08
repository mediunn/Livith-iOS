//
//  RequestTask.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum RequestTask {
    case plain
    case query([URLQueryItem])
    case body(any Encodable)
    case queryAndBody(queryItems: [URLQueryItem], body: any Encodable)
}
