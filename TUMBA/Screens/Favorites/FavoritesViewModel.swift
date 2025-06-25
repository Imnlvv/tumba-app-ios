import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favoritePosts: [Post] = []
    @Published var isLoading = false
    
    // MARK: Загрузка избранных постов
    func fetchFavoritePosts() {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else { return }
        
        isLoading = true
        ProfileService.shared.fetchFavoritePosts(userId: currentUserId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let posts):
                    self?.favoritePosts = posts
                case .failure(let error):
                    print("Error fetching favorite posts: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: Удаление избранных постов
    func removeFromFavorites(postId: Int) {
        favoritePosts.removeAll { $0.id == postId }
        
        // Отправляем запрос на сервер
        ProfileService.shared.toggleLike(postId: postId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Post removed from favorites")
                case .failure(let error):
                    print("Error removing from favorites:", error.localizedDescription)
                    // В случае ошибки можно вернуть пост в список
                    self?.fetchFavoritePosts()
                }
            }
        }
    }
    
    func remove(postId: Int) {
        favoritePosts.removeAll { $0.id == postId }
    }
}
