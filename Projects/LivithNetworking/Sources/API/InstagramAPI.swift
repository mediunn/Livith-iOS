//
//  InstagramAPI.swift
//  LivithNetworking
//
//  Created by youz2me on 7/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum InstagramAPI {
    public static func createExtractionJob(instagramURL: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/extraction-jobs",
            method: .post,
            task: .body(DTO.Request.CreateExtractionJob(instagramUrl: instagramURL)),
            authentication: .required
        )
    }
}
