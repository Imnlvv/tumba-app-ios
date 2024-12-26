import SwiftUI

struct PostsFeedView: View {
    @State private var posts: [Post] = [] // Список постов, полученных из API
    @State private var isLoading: Bool = true // Индикатор загрузки

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Загрузка постов...")
                    .padding()
            } else if posts.isEmpty {
                Text("Нет постов для отображения")
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(posts) { post in
                            PostView(post: post)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .onAppear {
            loadPosts()
        }
    }

    private func loadPosts() {
        PostService.shared.fetchPosts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPosts):
                    posts = fetchedPosts
                case .failure(let error):
                    print("Ошибка загрузки постов: \(error.localizedDescription)")
                }
                isLoading = false
            }
        }
    }
}
