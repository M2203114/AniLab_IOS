import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
            
            CatalogView()
                .tabItem {
                    Label("Каталог", systemImage: "list.bullet")
                }
            
            SearchView()
                .tabItem {
                    Label("Поиск", systemImage: "magnifyingglass")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Избранное", systemImage: "heart.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
        .accentColor(.blue)
    }
}

class ContentViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        // Initialize services and load initial data
    }
}
