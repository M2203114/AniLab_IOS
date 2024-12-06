import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}

class APIService {
    static let shared = APIService()
    private let baseURL = "https://api.anilabx.xyz"
    
    private init() {}
    
    func fetchContent(type: MediaType, page: Int = 1) -> AnyPublisher<[MediaContent], APIError> {
        let endpoint = "\(baseURL)/\(type.rawValue)?page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [MediaContent].self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return .decodingError(decodingError)
                }
                return .networkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func search(query: String, type: MediaType? = nil) -> AnyPublisher<[MediaContent], APIError> {
        var endpoint = "\(baseURL)/search?q=\(query)"
        if let type = type {
            endpoint += "&type=\(type.rawValue)"
        }
        
        guard let url = URL(string: endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [MediaContent].self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return .decodingError(decodingError)
                }
                return .networkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchEpisodes(for contentId: String) -> AnyPublisher<[Episode], APIError> {
        let endpoint = "\(baseURL)/content/\(contentId)/episodes"
        
        guard let url = URL(string: endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Episode].self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return .decodingError(decodingError)
                }
                return .networkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchChapters(for contentId: String) -> AnyPublisher<[Chapter], APIError> {
        let endpoint = "\(baseURL)/content/\(contentId)/chapters"
        
        guard let url = URL(string: endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Chapter].self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return .decodingError(decodingError)
                }
                return .networkError(error)
            }
            .eraseToAnyPublisher()
    }
}
