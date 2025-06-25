import Foundation
import UIKit

class EditPostViewModel: ObservableObject {
    @Published var title: String
    @Published var description: String
    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var isUpdating = false
    @Published var errorMessage: String?
    @Published var allTags: [Tag] = []
    @Published var selectedTags: [Tag] = []
    @Published var tagSearchText = ""
    @Published var filteredTags: [Tag] = []
    @Published var isLoadingTags = false
    @Published var newUIImage: UIImage? = nil 
    
    let postId: Int
    let currentImageUrl: URL?
    
    // Проверяем валидность форм
    var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty
    }
    
    init(post: Post) {
        self.postId = post.id
        self.title = post.title
        self.description = post.description
        self.currentImageUrl = URL(string: post.imageUrl?.fullUrl ?? "")
        self.selectedTags = post.tags.map {
            Tag(
                id: UUID().hashValue,
                name: $0,
                taggingsCount: 0,
                tagCategoryName: ""
            )
        }
        self.loadTags()
    }
    
    // MARK: Обновить пост
    func updatePost(completion: @escaping (Bool) -> Void) {
        isUpdating = true
        
        let tags = selectedTags.map { $0.name }
        
        PostService.shared.updatePost(
            postId: postId,
            title: title,
            description: description,
            tags: tags,
            image: selectedImage
        ) { result in
            DispatchQueue.main.async {
                self.isUpdating = false
                switch result {
                case .success:
                    completion(true)
                case .failure:
                    self.errorMessage = "Ошибка при обновлении поста"
                    completion(false)
                }
            }
        }
    }
    
    // MARK: Прогрузка тегов
    private func loadTags() {
        isLoadingTags = true
        TagService.shared.fetchTags { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingTags = false
                switch result {
                case .success(let tags):
                    self?.allTags = tags
                    self?.filteredTags = tags
                case .failure(let error):
                    self?.errorMessage = "Ошибка загрузки тегов: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: Поиск тегов
    func searchTags(query: String) {
        if query.isEmpty {
            filteredTags = allTags
        } else {
            filteredTags = allTags.filter {
                $0.name.localizedCaseInsensitiveContains(query)
            }
        }
    }

    // MARK: Выбрать тег
    func toggleTagSelection(_ tag: Tag) {
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
}
