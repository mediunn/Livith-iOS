//
//  CommentDataAssembler.swift
//  CommentData
//
//  Created by 김진웅 on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetworking

public struct CommentDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerCommentRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension CommentDataAssembler {
    func registerCommentRepository(to container: any DependencyContainer) {
        let client = container.resolve(NetworkClient.self)
        let commentRepo = CommentRepositoryImpl(
            networkClient: client
        )
        container.register(commentRepo, for: CommentRepository.self)
    }
}
