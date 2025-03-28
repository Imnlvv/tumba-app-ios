import SwiftUI
import PhotosUI

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var selectedImage: UIImage?
    @Published var selectedImageItem: PhotosPickerItem?
    @Published var isStepTwo: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isUploading: Bool = false
    @Published var isRegistered: Bool = false

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    // MARK: Регистрация
    func register() {
        isUploading = true

        AuthService.shared.register(
            name: name,
            username: username,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let authResponse):
                    if let profileId = authResponse.user.profile?.id {
                        print("Успешная регистрация. Profile ID: \(profileId)")
                        
                        if let image = self.selectedImage {
                            self.updateProfileWithAvatar(profileId: profileId, image: image)
                        } else {
                            self.updateProfile(profileId: profileId)
                        }
                    } else {
                        self.showError(message: "Ошибка: отсутствует profile.id")
                    }
                case .failure(let error):
                    self.showError(message: "Ошибка регистрации: \(error.localizedDescription)")
                    self.isUploading = false
                }
            }
        }
    }
    
    // MARK: Обновление профиля
    private func updateProfile(profileId: Int) {
        AuthService.shared.updateProfile(
            profileId: profileId,
            name: self.name,
            username: self.username
        ) { [weak self] (result: Result<Profile, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isUploading = false
                switch result {
                case .success(let profile):
                    print("Профиль обновлён: \(profile.username)")
                    self.fetchUserProfile(profileId: profileId)
                case .failure(let error):
                    self.showError(message: "Ошибка обновления профиля: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Обновление профиля с аватаром
    private func updateProfileWithAvatar(profileId: Int, image: UIImage) {
        AuthService.shared.updateProfileWithAvatar(
            profileId: profileId,
            name: self.name,
            username: self.username,
            image: image
        ) { [weak self] (result: Result<Profile, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isUploading = false
                switch result {
                case .success(let profile):
                    print("Профиль с аватаром обновлён: \(profile.username)")
                    self.fetchUserProfile(profileId: profileId)
                case .failure(let error):
                    self.showError(message: "Ошибка загрузки аватара: \(error.localizedDescription)")
                    // Пробуем обновить без аватара
                    self.updateProfile(profileId: profileId)
                }
            }
        }
    }
    
    // MARK: Секция ошибок
    private func showError(message: String) {
        self.showError = true
        self.errorMessage = message
        self.isUploading = false
    }
    
    // MARK: User -> Profile
    func nextStep() {
        if isStepTwo {
            register()
        } else {
            guard !email.isEmpty, !password.isEmpty, password == passwordConfirmation else {
                showError(message: "Заполните все поля и убедитесь, что пароли совпадают")
                return
            }
            isStepTwo = true
        }
    }

    // MARK: Загрузка изображения
    func loadImage() {
        guard let selectedImageItem = selectedImageItem else { return }
        Task {
            do {
                if let data = try await selectedImageItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.selectedImage = image
                    }
                }
            } catch {
                print("Ошибка загрузки изображения: \(error)")
            }
        }
    }
    
    // MARK: Подгрузка профиля
    private func fetchUserProfile(profileId: Int) {
        AuthService.shared.fetchUserProfile(profileId: profileId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userWithProfile):
                    AuthService.shared.storeUser(userWithProfile)
                    self.isLoggedIn = true
                    self.isRegistered = true
                case .failure(let error):
                    self.showError(message: "Ошибка загрузки профиля: \(error.localizedDescription)")
                }
            }
        }
    }
}
