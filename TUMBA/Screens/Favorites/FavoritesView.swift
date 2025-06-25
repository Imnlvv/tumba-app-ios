import SwiftUI
import WaterfallGrid

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var isGridViewActive = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if viewModel.isLoading {
                        // Загрузка избранного
                        loadingSection
                    } else if viewModel.favoritePosts.isEmpty {
                        // Отсутствие избранного
                        emptyStateSection
                    } else {
                        // Избранное
                        headerSection
                        postsContentSection
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchFavoritePosts()
            }
        }
    }
    
    // MARK: - func()

    // Верхняя секция (заголовок + переключатель вида)
    private var headerSection: some View {
        VStack(spacing: 0) {
            Text("Сохраненное".uppercased())
                .frame(maxWidth: .infinity)
                .font(.system(size: 21))
                .fontWeight(.medium)
                .foregroundColor(Color.Custom.gray)
                .padding(.bottom, 16)
            
            viewTypeToggle
        }
    }
    
    // Переключатель вида постов (сетка или лента)
    private var viewTypeToggle: some View {
        HStack {
            HStack(spacing: 16) {
                // Кнопка сетки
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isGridViewActive = true
                    }
                }) {
                    Image("square.grid.2x2_icon")
                        .font(.system(size: 20))
                        .foregroundColor(Color.Custom.gray)
                        .opacity(isGridViewActive ? 1.0 : 0.5)
                }
                // Кнопка списка
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isGridViewActive = false
                    }
                }) {
                    Image("list.bullet_icon")
                        .font(.system(size: 20))
                        .foregroundColor(Color.Custom.gray)
                        .opacity(isGridViewActive ? 0.5 : 1.0)
                }
            }
            .padding(.leading, 16)
            .padding(.bottom, 30)
            Spacer()
        }
    }
    
    // Основной контент с постами
    private var postsContentSection: some View {
        Group {
            if isGridViewActive {
                // Водопадная сетка
                ScrollView {
                    WaterfallGrid(viewModel.favoritePosts, id: \.id) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            FavoritePostView(post: post) {
                                viewModel.remove(postId: post.id)
                            }
                            .frame(width: (UIScreen.main.bounds.width - 38) / 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .gridStyle(
                        columns: 2,
                        spacing: 10,
                        animation: .easeInOut
                    )
                    .padding(.bottom, 10)
                }
                .frame(width: 370)
            } else {
                // Обычная лента
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.favoritePosts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            FavoritePostView(post: post) {
                                viewModel.remove(postId: post.id)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .frame(width: 367)
            }
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    // Прогрузка постов
    private var loadingSection: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
    }
    
    // Отсутствие постов
    private var emptyStateSection: some View {
        Text("Нет избранных постов")
            .font(.headline)
            .foregroundColor(.gray)
            .padding()
    }
}

// MARK: - FavoritePostView

struct FavoritePostView: View {
    let post: Post
    var onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            PostView(post: post)
            
            Button(action: onDelete) {
                Image("favorite_icon")
                    .resizable()
                    .frame(width: 42, height: 42)
            }
        }
    }
}
