import SwiftUI
import PhotosUI

class EditProfileViewModel: ObservableObject {
    @Published var name: String
    @Published var username: String
    @Published var selectedImage: UIImage?
    @Published var selectedImageItem: PhotosPickerItem?
    @Published var isSaving = false
    @Published var errorMessage: String?
    
    var onSave: (String, String, UIImage?) -> Void
    
    init(name: String, username: String, onSave: @escaping (String, String, UIImage?) -> Void) {
        self.name = name
        self.username = username
        self.onSave = onSave
    }
    
    // MARK: Сохранение изменений
    func saveChanges() {
        isSaving = true
        errorMessage = nil
        
        if let image = selectedImage {
            AuthService.shared.uploadAvatar(image: image) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isSaving = false
                    switch result {
                    case .success(let profile):
                        self?.onSave(profile.name, profile.username, self?.selectedImage)
                    case .failure(let error):
                        self?.errorMessage = "Ошибка загрузки аватара: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            AuthService.shared.updateProfile(
                name: name,
                username: username,
                avatarUrl: nil
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isSaving = false
                    switch result {
                    case .success(let profile):
                        self?.onSave(profile.name, profile.username, nil)
                    case .failure(let error):
                        self?.errorMessage = "Ошибка обновления профиля: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}
