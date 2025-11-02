import SwiftUI

import LoginFeature
import SearchFeature
import DesignSystem

@main
struct LivithApp: App {
    
    // MARK: - LifeCycle

    init() {
        Font.registerFont()
    }

    var body: some Scene {
        WindowGroup {
            SearchView()
        }
    }
}
