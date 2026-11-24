import SwiftUI

import Domain

public extension EnvironmentValues {
    @Entry var concertCatalogRepository: (any ConcertCatalogRepository)? = nil
    @Entry var searchRepository: (any SearchRepository)? = nil
}
