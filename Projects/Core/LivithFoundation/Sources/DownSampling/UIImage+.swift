//
//  UIImage+.swift
//  Livithfoundation
//
//  Created by Youjin Lee on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import UIKit

public extension UIImage {
    /// 이미지의 픽셀 면적이 maxPixelArea를 초과하면 비율을 유지하며 축소한 JPEG Data를 반환합니다.
    func downsampledData(
        maxPixelArea: CGFloat = 400_000,
        compressionQuality: CGFloat = 0.7
    ) -> Data? {
        let pixelWidth = size.width * scale
        let pixelHeight = size.height * scale
        let currentArea = pixelWidth * pixelHeight

        guard currentArea > maxPixelArea else {
            return jpegData(compressionQuality: compressionQuality)
        }

        let scaleFactor = sqrt(maxPixelArea / currentArea)
        let newSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.jpegData(withCompressionQuality: compressionQuality) { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
