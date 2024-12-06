import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if !viewModel.continueWatching.isEmpty {
                        MediaRow(
                            title: "Продолжить просмотр",
                            content: viewModel.continueWatching,
                            onViewAll: { /* Navigate to history */ }
                        )
                    }
                    
                    MediaRow(
                        title: "Популярное аниме",
                        content: viewModel.popularAnime,
                        onViewAll: { /* Navigate to anime catalog */ }
                    )
                    
                    MediaRow(
                        title: "Популярные дорамы",
                        content: viewModel.popularDramas,
                        onViewAll: { /* Navigate to drama catalog */ }
                    )
                    
                    MediaRow(
                        title: "Недавно обновлено",
                        content: viewModel.recentlyUpdated,
                        onViewAll: { /* Navigate to updates */ }
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("AniLabX")
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.2))
                    }
                }
            )
            .alert(item: Binding(
                get: { viewModel.error.map { ErrorWrapper(error: $0) } },
                set: { _ in viewModel.error = nil }
            )) { wrapper in
                Alert(
                    title: Text("Ошибка"),
                    message: Text(wrapper.error.localizedDescription),
                    primaryButton: .default(Text("Повторить")) {
                        viewModel.retryLoading()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            viewModel.loadContent()
        }
    }
}

// Wrapper для отображения ошибки в Alert
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: Error
}
