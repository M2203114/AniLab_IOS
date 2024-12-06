import Foundation
import Combine

class CatalogViewModel: ObservableObject {
    @Published var content: [MediaContent] = []
    @Published var filter = CatalogFilter()
    @Published var isLoading = false
    @Published var error: Error?
    @Published var filterGroups: [FilterGroup] = []
    @Published var showFilters = false
    @Published var hasMoreContent = true
    
    private var currentPage = 1
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    
    init() {
        setupFilterGroups()
        loadContent()
    }
    
    private func setupFilterGroups() {
        filterGroups = [
            FilterGroup(id: "genres", title: "Жанры", filters: [
                Filter(id: 1, name: "Боевик"),
                Filter(id: 2, name: "Комедия"),
                Filter(id: 3, name: "Драма"),
                Filter(id: 4, name: "Фэнтези"),
                Filter(id: 5, name: "Романтика"),
                Filter(id: 6, name: "Научная фантастика"),
                Filter(id: 7, name: "Повседневность"),
                Filter(id: 8, name: "Приключения"),
                Filter(id: 9, name: "Психологическое"),
                Filter(id: 10, name: "Сёнэн")
            ]),
            FilterGroup(id: "status", title: "Статус", filters: [
                Filter(id: 101, name: "Онгоинг"),
                Filter(id: 102, name: "Завершён"),
                Filter(id: 103, name: "Анонс")
            ]),
            FilterGroup(id: "season", title: "Сезон", filters: [
                Filter(id: 201, name: "Зима"),
                Filter(id: 202, name: "Весна"),
                Filter(id: 203, name: "Лето"),
                Filter(id: 204, name: "Осень")
            ])
        ]
    }
    
    func loadContent(refresh: Bool = false) {
        if refresh {
            currentPage = 1
            content = []
            hasMoreContent = true
        }
        
        guard hasMoreContent else { return }
        
        isLoading = true
        error = nil
        
        // Создаем параметры запроса на основе фильтров
        var parameters: [String: Any] = [
            "type": filter.mediaType.rawValue,
            "sort": filter.sortBy.rawValue,
            "page": currentPage
        ]
        
        if !filter.genres.isEmpty {
            parameters["genres"] = Array(filter.genres)
        }
        if let status = filter.status {
            parameters["status"] = status
        }
        if let year = filter.year {
            parameters["year"] = year
        }
        if let season = filter.season {
            parameters["season"] = season
        }
        
        apiService.fetchContent(type: filter.mediaType, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] newContent in
                guard let self = self else { return }
                if refresh {
                    self.content = newContent
                } else {
                    self.content.append(contentsOf: newContent)
                }
                self.hasMoreContent = !newContent.isEmpty
                self.currentPage += 1
            }
            .store(in: &cancellables)
    }
    
    func toggleFilter(_ filter: Filter, in group: FilterGroup) {
        guard let groupIndex = filterGroups.firstIndex(where: { $0.id == group.id }),
              let filterIndex = filterGroups[groupIndex].filters.firstIndex(where: { $0.id == filter.id })
        else { return }
        
        filterGroups[groupIndex].filters[filterIndex].isSelected.toggle()
        
        // Обновляем основной фильтр
        switch group.id {
        case "genres":
            if filterGroups[groupIndex].filters[filterIndex].isSelected {
                self.filter.genres.insert(filter.name)
            } else {
                self.filter.genres.remove(filter.name)
            }
        case "status":
            self.filter.status = filterGroups[groupIndex].filters[filterIndex].isSelected ? filter.name : nil
        case "season":
            self.filter.season = filterGroups[groupIndex].filters[filterIndex].isSelected ? filter.name : nil
        default:
            break
        }
    }
    
    func applyFilters() {
        showFilters = false
        loadContent(refresh: true)
    }
    
    func resetFilters() {
        filter = CatalogFilter()
        for i in filterGroups.indices {
            for j in filterGroups[i].filters.indices {
                filterGroups[i].filters[j].isSelected = false
            }
        }
    }
}
