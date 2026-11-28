//
//  BackgroundGradientView.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct BackgroundGradientView: View {
    private let baseColor: Color
    private let transparentOpacity: Double
    private let startPoint: UnitPoint
    private let endPoint: UnitPoint

    public init(
        baseColor: Color = Color(red: 0.08, green: 0.09, blue: 0.11),
        transparentOpacity: Double = 0,
        startPoint: UnitPoint = UnitPoint(x: 0.5, y: 1),
        endPoint: UnitPoint = UnitPoint(x: 0.5, y: 0)
    ) {
        self.baseColor = baseColor
        self.transparentOpacity = transparentOpacity
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    public var body: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: baseColor, location: 0.00),
                Gradient.Stop(color: baseColor.opacity(transparentOpacity), location: 1.00),
            ],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

#Preview {
    VStack(spacing: 8) {
        Text("Preview")
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(BackgroundGradientView())
            .frame(height: 60)

        Text("Custom Gradient")
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(BackgroundGradientView(baseColor: .blue, transparentOpacity: 0.0))
            .frame(height: 60)
    }
    .background(Color.black)
}
