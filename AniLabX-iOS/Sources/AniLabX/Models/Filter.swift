import Foundation

struct Filter: Identifiable {
    let id: Int
    let name: String
    var isSelected: Bool = false
}

struct FilterGroup: Identifiable {
    let id: String
    let title: String
    var filters: [Filter]
}

struct CatalogFilter {
    var mediaType: MediaType = .anime
    var sortBy: SortOption = .popularity
    var genres: Set<String> = []
    var status: String?
    var year: Int?
    var season: String?
    
    enum SortOption: String, CaseIterable {
        case popularity = "По популярности"
        case rating = "По рейтингу"
        case newest = "Сначала новые"
        case oldest = "Сначала старые"
        case nameAsc = "По названию (А-Я)"
        case nameDesc = "По названию (Я-А)"
    }
}
