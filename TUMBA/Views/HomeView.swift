import SwiftUI

struct HomeView: View {
    @State private var searchText: String = "" // Текст поиска
    @State private var selectedTags: Set<Int> = [] // Выбранные теги
    @State private var tags: [Tag] = [] // Список тегов
    @State private var posts: [Post] = [] // Список всех постов
    @State private var filteredPosts: [Post] = [] // Отфильтрованные посты

    var body: some View {
        VStack(spacing: 0) {
            // Верхний блок с навигацией
            VStack(spacing: 10) {
                // Поисковая строка
                SearchBarView(searchText: $searchText)
                    .padding(.top, 10)
                    .onChange(of: searchText) { _ in
                        applyFilters()
                    }

                // Фильтрация по тегам
                TagsFilterView(selectedTags: $selectedTags, tags: tags) { _ in
                    applyFilters()
                }
            }
            .frame(maxWidth: .infinity, alignment: .top) // Растягиваем VStack по ширине и прикрепляем вверх
            .padding(.top, -35)
            .background(Color.white) // Добавляем фон, чтобы скрыть возможные пустоты
            .edgesIgnoringSafeArea(.top) // Игнорируем безопасную зону сверху
            .background(Color.white)
            .onAppear {
                loadTags()
                loadPosts()
            }
            .frame(height: 76)

            Spacer()
            // Лента постов
            if filteredPosts.isEmpty {
                Text("Нет подходящих постов.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredPosts) { post in
                            PostView(post: post)
                        }
                    }
                }
                .padding(.top, 10)
            }
            Spacer()
        }
    }

    // Метод для загрузки тегов
    private func loadTags() {
        TagService.shared.fetchTags { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedTags):
                    tags = loadedTags
                case .failure(let error):
                    print("Ошибка загрузки тегов: \(error.localizedDescription)")
                }
            }
        }
    }

    // Метод для загрузки постов
    private func loadPosts() {
        PostService.shared.fetchPosts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedPosts):
                    posts = loadedPosts
                    applyFilters()
                case .failure(let error):
                    print("Ошибка загрузки постов: \(error.localizedDescription)")
                }
            }
        }
    }

    // Применение фильтров
    private func applyFilters() {
        filteredPosts = posts.filter { post in
            // Проверяем соответствие выбранным тегам
            let matchesTags = selectedTags.isEmpty || selectedTags.allSatisfy { tagId in
                guard let tagName = tags.first(where: { $0.id == tagId })?.name,
                      let postTags = post.tags else {
                    return false
                }
                return postTags.contains(where: { $0.localizedCaseInsensitiveContains(tagName) })
            }

            // Проверяем соответствие поисковому запросу
            let matchesSearch = searchText.isEmpty || {
                let lowercasedSearch = searchText.lowercased()
                let titleMatches = post.title.lowercased().contains(lowercasedSearch)
                let descriptionMatches = post.description.lowercased().contains(lowercasedSearch)
                let authorNameMatches = post.profile.name.lowercased().contains(lowercasedSearch)
                return titleMatches || descriptionMatches || authorNameMatches
            }()

            return matchesTags && matchesSearch
        }
    }
}
