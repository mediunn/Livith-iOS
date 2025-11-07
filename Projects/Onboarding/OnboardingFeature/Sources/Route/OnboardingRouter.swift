//
//  OnboardingRouter.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Routing

@MainActor
final class OnboardingRouter: Routing, ObservableObject {
    typealias Route = OnboardingRoute
    
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: OnboardingRoute?
    @Published var fullScreenCover: OnboardingRoute?
    
    func view(to route: OnboardingRoute, with style: PresentationStyle) -> AnyView {
        switch route {
        case .terms:
            return AnyView(TermsView())
        case .nickname:
            return AnyView(NicknameSettingView())
        case .signupFailed:
            return AnyView(SignupFailedSheetView())
        }
    }
}
