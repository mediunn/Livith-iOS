//
//  UserRouter.swift
//  User
//
//  Created by Youjin Lee on 12/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import Routing

@MainActor
final class UserRouter: Routing, ObservableObject {
    typealias Route = UserRoute
    
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: UserRoute?
    @Published var fullScreenCover: UserRoute?
    
    func view(to route: UserRoute, with style: PresentationStyle) -> AnyView {
        switch route {
        case .user:
            return AnyView(UserView(nickname: "냐미"))
        case .updateProfile:
            return AnyView(NicknameUpdateView())
        case .updateNote:
            guard let url = URL(string: Constant.updateNoteURLString) else { }
            return AnyView(SafariView(url: url))
        case .terms:
            guard let url = URL(string: Constant.termsURLString) else { }
            return AnyView(SafariView(url: url))
        case .logout:
            <#code#>
        case .unRegistered:
            <#code#>
        }
    }
}

// MARK: - Constants

private extension UserRouter {
    enum Constant {
        static let updateNoteURLString: String = "https://youz2me.notion.site/Livith-v-25-04-13-1d402dd0e5fc80eaacd9d3dfdc7d0aa0"
        static let termsURLString: String = "https://youz2me.notion.site/Livith-v-25-11-18-1d402dd0e5fc800dab7fc177f325eade"
    }
}
