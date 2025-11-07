import SwiftUI

import LoginFeature
import SearchFeature
import DesignSystem

@main
struct LivithApp: App {
    
    // MARK: - LifeCycle

    init() {
        registerDependency()
    }

    var body: some Scene {
        WindowGroup {
            SearchView(store: SearchStore())
                .background(Color.livithColor(.black100))
        }
    }
}
