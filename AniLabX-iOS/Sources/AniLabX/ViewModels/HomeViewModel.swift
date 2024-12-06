import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var popularAnime: [MediaContent] = []
    @Published var popularDramas: [MediaContent] = []
    @Published var recentlyUpdated: [MediaContent] = []
    @Published var continueWatching: [MediaContent] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    private let storageService = StorageService.shared
    
    func loadContent() {
        isLoading = true
        
        // Загрузка популярного аниме
        apiService.fetchContent(type: .anime)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] content in
                self?.popularAnime = Array(content.prefix(10))
            }
            .store(in: &cancellables)
        
        // Загрузка популярных дорам
        apiService.fetchContent(type: .drama)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] content in
                self?.popularDramas = Array(content.prefix(10))
            }
            .store(in: &cancellables)
        
        // Загрузка недавно обновленных
        let recentTypes: [MediaType] = [.anime, .drama, .manga]
        Publishers.MergeMany(recentTypes.map { type in
            apiService.fetchContent(type: type)
        })
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.error = error
            }
        } receiveValue: { [weak self] content in
            self?.recentlyUpdated.append(contentsOf: content)
            self?.recentlyUpdated.sort { $0.releaseDate > $1.releaseDate }
            self?.recentlyUpdated = Array(self?.recentlyUpdated.prefix(20) ?? [])
        }
        .store(in: &cancellables)
        
        // Загрузка "Продолжить просмотр" из локального хранилища
        // TODO: Реализовать загрузку из CoreData
    }
    
    func retryLoading() {
        error = nil
        loadContent()
    }
}
