import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @AppStorage("isLoggedIn") private var isLoggedIn = true

    // MARK: Информация о постах в профиле
    func loadProfile() {
        guard isLoggedIn else { return }

        isLoading = true
        errorMessage = nil

        AuthService.shared.fetchCurrentUserProfile { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let profile):
                    self.profile = profile
//                    print("Загруженные посты: \(String(describing: profile.posts))")
                    print("Количество постов: \(profile.posts?.count ?? -1)")

                    if let posts = profile.posts, !posts.isEmpty {
                        print("Посты успешно загружены")
                    } else {
                        print("Нет постов в профиле")
                    }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Ошибка загрузки профиля: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Выход
    func logout() {
        AuthService.shared.logout { success in
            DispatchQueue.main.async {
                if success {
                    self.isLoggedIn = false
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        window.rootViewController = UIHostingController(rootView: LoginView())
                        window.makeKeyAndVisible()
                    }
                } else {
                    print("Ошибка выхода из системы")
                }
            }
        }
    }

    // MARK: Удаление аккаунта
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        AuthService.shared.deleteAccount { success in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    // Успешное удаление аккаунта
                    self.isLoggedIn = false
                    self.profile = nil
                    completion(true)
                } else {
                    // Ошибка при удалении аккаунта
                    self.errorMessage = "Не удалось удалить аккаунт"
                    completion(false)
                }
            }
        }
    }
    
    // MARK: Редактировать профиль
    func updateProfile(name: String, username: String, image: UIImage?) {
        isLoading = true
        errorMessage = nil
        
        if let image = image {
            AuthService.shared.uploadAvatar(image: image) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        // Принудительное обновление состояния
                        self?.profile = profile
                        self?.updateProfileData(name: name, username: username, avatarUrl: profile.avatarUrl)
                    case .failure(let error):
                        self?.isLoading = false
                        self?.errorMessage = "Ошибка загрузки аватара: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            updateProfileData(name: name, username: username, avatarUrl: nil)
        }
    }
    
    private func updateProfileData(name: String, username: String, avatarUrl: String?) {
        AuthService.shared.updateProfile(
            name: name,
            username: username,
            avatarUrl: avatarUrl
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let updatedProfile):
                    self?.profile = updatedProfile
                case .failure(let error):
                    self?.errorMessage = "Ошибка обновления профиля: \(error.localizedDescription)"
                }
            }
        }
    }
}
