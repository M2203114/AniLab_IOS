import SwiftUI

struct FilterView: View {
    @ObservedObject var viewModel: CatalogViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                // Тип медиа
                Section(header: Text("Тип")) {
                    Picker("Тип", selection: $viewModel.filter.mediaType) {
                        Text("Аниме").tag(MediaType.anime)
                        Text("Дорамы").tag(MediaType.drama)
                        Text("Мультфильмы").tag(MediaType.cartoon)
                        Text("Манга").tag(MediaType.manga)
                        Text("Комиксы").tag(MediaType.comic)
                        Text("Ранобэ").tag(MediaType.lightNovel)
                    }
                }
                
                // Сортировка
                Section(header: Text("Сортировка")) {
                    Picker("Сортировка", selection: $viewModel.filter.sortBy) {
                        ForEach(CatalogFilter.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
                
                // Группы фильтров
                ForEach(viewModel.filterGroups) { group in
                    Section(header: Text(group.title)) {
                        ForEach(group.filters) { filter in
                            FilterToggleRow(
                                filter: filter,
                                isSelected: group.filters.first { $0.id == filter.id }?.isSelected ?? false
                            ) {
                                viewModel.toggleFilter(filter, in: group)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Фильтры")
            .navigationBarItems(
                leading: Button("Сбросить") {
                    viewModel.resetFilters()
                },
                trailing: Button("Применить") {
                    viewModel.applyFilters()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct FilterToggleRow: View {
    let filter: Filter
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(filter.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
        .foregroundColor(.primary)
    }
}
