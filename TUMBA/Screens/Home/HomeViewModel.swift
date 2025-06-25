import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedTags: Set<Int> = []
    @Published var tags: [Tag] = []
    @Published var posts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var selectedPost: Post?
    @Published var isLoading: Bool = false
    @Published var selectedTab: Int = 0

    // MARK: Прогрузка тегов
    func loadTags() {
        TagService.shared.fetchTags { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedTags):
                    self.tags = loadedTags
                case .failure(let error):
                    print("Ошибка загрузки тегов: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Прогрузка постов
    func loadPosts() {
        isLoading = true
        PostService.shared.fetchPosts { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let loadedPosts):
                    self.posts = loadedPosts
                    self.applyFilters()
                case .failure(let error):
                    print("Ошибка загрузки постов: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Фильтрация тегов
    func applyFilters() {
        filteredPosts = posts.filter { post in
            // Фильтрация по тегам
            let matchesTags = selectedTags.isEmpty || selectedTags.allSatisfy { tagId in
                guard let tagName = tags.first(where: { $0.id == tagId })?.name else {
                    return false
                }
                let postTags = post.tags
                return postTags.contains(where: { $0.localizedCaseInsensitiveContains(tagName) })
            }

            // Фильтрация по поисковому запросу
            let matchesSearch = searchText.isEmpty || {
                let lowercasedSearch = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                let titleMatches = post.title.lowercased().contains(lowercasedSearch)
                let descriptionMatches = post.description.lowercased().contains(lowercasedSearch)
                let authorNameMatches = post.profile?.name.lowercased().contains(lowercasedSearch) ?? false
                
                return titleMatches || descriptionMatches || authorNameMatches
            }()

            return matchesTags && matchesSearch
        }
    }
}
