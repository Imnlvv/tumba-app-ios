import SwiftUI
import WaterfallGrid

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Верхняя секция (поиск и фильтры)
                topSection
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(Color.white)
                    .onAppear {
                        if viewModel.tags.isEmpty || viewModel.posts.isEmpty {
                            viewModel.loadTags()
                            viewModel.loadPosts()
                        }
                    }
                    .frame(height: 100)

                Spacer().frame(height: 25)

                // Основная секция (посты)
                if viewModel.isLoading {
                    loadingSection
                } else if viewModel.filteredPosts.isEmpty {
                    noPostsSection
                } else {
                    postsGridSection
                }

                Spacer()
            }
            .navigationDestination(isPresented: Binding(
                get: { viewModel.selectedPost != nil },
                set: { _ in viewModel.selectedPost = nil }
            )) {
                if let post = viewModel.selectedPost {
                    PostDetailView(post: post)
                }
            }
        }
    }
    
    // MARK: - func()

    // Верхняя секция (поиск и фильтры)
    private var topSection: some View {
        VStack(spacing: 25) {
            SearchBarView(searchText: $viewModel.searchText)
                .padding(.top, 5)
                .onChange(of: viewModel.searchText) { oldValue, newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.applyFilters()
                    }
                }

            TagsFilterView(selectedTags: $viewModel.selectedTags, tags: viewModel.tags) { _ in
                viewModel.applyFilters()
            }
        }
    }

    // Загрузка
    private var loadingSection: some View {
        ProgressView()
    }

    // "Нет постов"
    private var noPostsSection: some View {
        Text("Нет подходящих постов")
            .font(.headline)
            .foregroundColor(.gray)
            .padding()
    }

    // Основная секция (посты через гриды)
    private var postsGridSection: some View {
        ScrollView {
            WaterfallGrid(viewModel.filteredPosts, id: \.id) { post in
                Button(action: {
                    viewModel.selectedPost = post
                }) {
                    PostView(post: post)
                        .frame(width: (UIScreen.main.bounds.width - 38) / 2) // Фиксированная ширина
                }
                .buttonStyle(PlainButtonStyle())
            }
            .gridStyle(columns: 2, spacing: 10)
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 0, trailing: 14))
        }
    }
}
