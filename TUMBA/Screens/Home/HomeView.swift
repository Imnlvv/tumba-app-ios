import SwiftUI
import WaterfallGrid

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var lastScrollOffset: CGFloat = 0
    @State private var isTopSectionVisible = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Верхняя секция (поиск и фильтры)
                if isTopSectionVisible {
                    topSection
                        .frame(maxWidth: .infinity, alignment: .top)
                        .background(Color.white)
                        .onAppear {
                            if viewModel.tags.isEmpty || viewModel.posts.isEmpty {
                                viewModel.loadTags()
                                viewModel.loadPosts()
                            }
                        }
                        .zIndex(1) // Размещаем выше контента
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
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
            .animation(.easeInOut(duration: 0.25), value: isTopSectionVisible)
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

    // Поиск и теги
    private var topSection: some View {
        VStack(spacing: 25) {
            SearchBarView(searchText: $viewModel.searchText)
                .onChange(of: viewModel.searchText) { oldValue, newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.applyFilters()
                    }
                }

            TagsFilterView(selectedTags: $viewModel.selectedTags, tags: viewModel.tags) { _ in
                viewModel.applyFilters()
            }
        }
        .padding(.top, -30)
        .padding(.bottom, 15)
    }
    
    // Загрузка постов
    private var loadingSection: some View {
        ProgressView()
    }

    // Отсутствие постов
    private var noPostsSection: some View {
        Text("Нет подходящих постов")
            .font(.headline)
            .foregroundColor(.gray)
            .padding()
    }
    
    // Лента постов + скролл (анимация)
    private var postsGridSection: some View {
        ScrollView {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).origin.y)
            }
            .frame(height: 0)
            
            WaterfallGrid(viewModel.filteredPosts, id: \.id) { post in
                Button(action: {
                    viewModel.selectedPost = post
                }) {
                    PostView(post: post)
                        .frame(width: (UIScreen.main.bounds.width - 38) / 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .gridStyle(columns: 2, spacing: 10)
            .padding(EdgeInsets(top: 0, leading: 14, bottom: 15, trailing: 14))
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            let scrollOffset = offset
            let scrollDirection = scrollOffset > lastScrollOffset ? "down" : "up"
            let threshold: CGFloat = 70
            
            // Фильтрация небольших колебаний
            guard abs(scrollOffset - lastScrollOffset) > 1 else { return }
            lastScrollOffset = scrollOffset
            
            // Плавная анимация
            if scrollDirection == "up" && scrollOffset < -threshold {
                if isTopSectionVisible {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                            isTopSectionVisible = false
                        }
                    }
                }
            } else if scrollDirection == "down" {
                if !isTopSectionVisible {
                    withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                        isTopSectionVisible = true
                    }
                }
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}


// MARK: - Превью

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

