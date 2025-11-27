//
//  LivithApp+InjectDependency.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import SearchData

extension LivithApp {
    func registerDependency() {
        DIContainer.shared.register(
            assemblers: [
                SearchAssembler()
            ]
        )
    }
}
