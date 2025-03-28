import SwiftUI
import WaterfallGrid

struct PostsFeedView: View {
    @StateObject private var viewModel = PostsFeedViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Загрузка постов...")
                    .padding()
            } else if viewModel.posts.isEmpty {
                Text("Нет постов для отображения")
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    WaterfallGrid(viewModel.posts, id: \.id) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostView(post: post)
                                .frame(width: (UIScreen.main.bounds.width - 38) / 2) // Фиксированная ширина
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .gridStyle(columns: 2, spacing: 10)
                    .padding(EdgeInsets(top: 10, leading: 14, bottom: 0, trailing: 14))
                }
            }
            
            // Отображение ошибки (если есть)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            viewModel.loadPosts()
        }
    }
}
