import Foundation

enum MediaType: String, Codable {
    case anime
    case drama
    case cartoon
    case manga
    case comic
    case lightNovel
}

struct MediaContent: Identifiable, Codable {
    let id: String
    let title: String
    let originalTitle: String?
    let description: String
    let type: MediaType
    let coverImage: String
    let rating: Double
    let releaseDate: Date
    let genres: [String]
    let status: String
    var isFavorite: Bool
    
    // Для аниме/дорам/мультфильмов
    var episodes: [Episode]?
    
    // Для манги/комиксов/ранобэ
    var chapters: [Chapter]?
}

struct Episode: Identifiable, Codable {
    let id: String
    let number: Int
    let title: String
    let duration: TimeInterval
    let streamingURL: String
    var watchProgress: Double
}

struct Chapter: Identifiable, Codable {
    let id: String
    let number: Int
    let title: String
    let pages: [String] // URLs to pages
    var readProgress: Double
}
