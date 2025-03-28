import SwiftUI

class AddPostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var tags: String = ""
    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var isPosting = false

    let profileId: Int

    init(profileId: Int) {
        self.profileId = profileId
    }
    
    // MARK: Создание поста
    func createPost() {
        guard let image = selectedImage else { return }
        isPosting = true

        // Преобразуем теги в массив
        let tagsArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        // Передаем profileId вместе с другими параметрами
        PostService.shared.createPost(title: title, description: description, tags: tagsArray, image: image, profileId: profileId) { result in
            DispatchQueue.main.async {
                self.isPosting = false
                switch result {
                case .success(let newPost):
                    print("Успех! Пост создан: \(newPost)")
                case .failure(let error):
                    print("Ошибка создания поста: \(error.localizedDescription)")
                }
            }
        }
    }
}
