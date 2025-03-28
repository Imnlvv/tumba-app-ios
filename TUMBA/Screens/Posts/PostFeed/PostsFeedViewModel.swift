import SwiftUI
import Combine

class PostsFeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Прогрузка постов
    func loadPosts() {
        PostService.shared.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPosts):
                    self?.posts = fetchedPosts
                case .failure(let error):
                    self?.errorMessage = "Ошибка загрузки постов: \(error.localizedDescription)"
                }
                self?.isLoading = false
            }
        }
    }
}
