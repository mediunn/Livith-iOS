//
//  MultipartData.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

/// Multipart 업로드에 사용할 데이터 구조체
public struct MultipartData {
    public let data: Data
    public let name: String
    public let fileName: String
    public let mimeType: String

    public init(
        data: Data,
        name: String,
        fileName: String,
        mimeType: String
    ) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
