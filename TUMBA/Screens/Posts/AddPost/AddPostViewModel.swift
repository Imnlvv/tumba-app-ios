import SwiftUI
import PhotosUI

class AddPostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var isPosting = false
    @Published var errorMessage: String?
    @Published var selectedTags: [Tag] = []
    @Published var allTags: [Tag] = []
    @Published var filteredTags: [Tag] = []
    @Published var tagSearchText: String = ""
    @Published var isLoadingTags = false
    @Published var itemLinks: [String] = []
    @Published var currentItemLink: String = ""
    @Published var items: [Item] = []
    @Published var isAddingItem = false
    @Published var itemError: String?
    
    let profileId: Int

    init(profileId: Int) {
        self.profileId = profileId
        loadTags()
    }
    
    // MARK: Проверка валидности
    var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        selectedImage != nil
    }
        
    // MARK: Загрузка тегов
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
    
    // MARK: Регулирование тегов
    func toggleTagSelection(_ tag: Tag) {
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
    
    // MARK: Удаление товаров
    func removeItem(at index: Int) {
        items.remove(at: index)
        itemLinks.remove(at: index)
    }

    // MARK: Создание поста
    func createPost(completion: @escaping (Bool) -> Void) {
        guard isFormValid else {
            errorMessage = "Заполните все обязательные поля"
            completion(false)
            return
        }
        
        guard let image = selectedImage else {
            errorMessage = "Выберите изображение"
            completion(false)
            return
        }
        
        isPosting = true
        errorMessage = nil
        
        let tagNames = selectedTags.map { $0.name }
        
        PostService.shared.createPost(
            title: title,
            description: description,
            tags: tagNames,
            image: image,
            profileId: profileId
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isPosting = false
                switch result {
                case .success:
                    self?.resetForm()
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    // MARK: Очищение формы
    private func resetForm() {
        title = ""
        description = ""
        selectedImage = nil
        selectedTags = []
        currentItemLink = ""
        items.removeAll()
        itemLinks.removeAll()
        itemError = nil
    }
}
