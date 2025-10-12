//
//  Routable.swift
//  core
//
//  Created by 김진웅 on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol Routable: Hashable, Identifiable, RawRepresentable {}

public extension Routable where RawValue == String {
    var id: String { rawValue }
}