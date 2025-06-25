import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isCurrentUser: Bool = true
    
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    
    private let userId: Int?
    
    // Инициализатор для текущего пользователя
    init() {
        self.userId = nil
        self.isCurrentUser = true
    }
    
    // Инициализатор для чужого профиля
    init(userId: Int) {
        self.userId = userId
        self.isCurrentUser = AuthService.shared.getCurrentUserId() == userId
    }
    
    // MARK: Загрузка профиля
    func loadProfile() {
        guard isLoggedIn || !isCurrentUser else { return }
        
        isLoading = true
        errorMessage = nil
        
        if isCurrentUser {
            AuthService.shared.fetchCurrentUserProfile { [weak self] (result: Result<Profile, Error>) in
                self?.handleProfileResult(result)
                self?.loadCurrentUserPosts()
            }
        } else if let userId = userId {
            ProfileService.shared.fetchProfile(for: userId) { [weak self] (result: Result<Profile, Error>) in
                self?.handleProfileResult(result)
                self?.loadUserPosts(userId: userId)
            }
        }
    }
    
    // MARK: Загрузка постов (чужих/своих)
    private func loadUserPosts(userId: Int) {
        PostService.shared.fetchPosts { [weak self] (result: Result<[Post], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    // Фильтруем посты, где profile.id совпадает с userId
                    let userPosts = posts.filter { $0.profile?.id == userId }
                    self?.profile?.posts = userPosts
                case .failure(let error):
                    print("Ошибка загрузки постов: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadCurrentUserPosts() {
        guard let userId = AuthService.shared.getCurrentUserId() else { return }
        loadUserPosts(userId: userId)
    }
    
    private func handleProfileResult(_ result: Result<Profile, Error>) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            switch result {
            case .success(let profile):
                print("Профиль загружен: \(profile.username)")
                self?.profile = profile
//                print("Текущий профиль: \(String(describing: self?.profile))")
            case .failure(let error):
                print("Ошибка профиля: \(error.localizedDescription)")
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: Подписки/Отписки
    func toggleFollowStatus() {
        guard let userId = userId else { return }
        
        if profile?.isFollowing == true {
            // Логика отписки
            ProfileService.shared.unfollowUser(userId: userId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.profile?.isFollowing = false
                        self?.profile?.subscribers -= 1
                    case .failure(let error):
                        self?.errorMessage = "Ошибка отписки: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            // Логика подписки
            ProfileService.shared.followUser(userId: userId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.profile?.isFollowing = true
                        self?.profile?.subscribers += 1
                    case .failure(let error):
                        self?.errorMessage = "Ошибка подписки: \(error.localizedDescription)"
                    }
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
    
    // MARK: Удалить пост
    func removePost(withId postId: Int) {
        guard var currentProfile = profile else { return }
        currentProfile.posts?.removeAll { $0.id == postId }
        self.profile = currentProfile
    }
    
    // MARK: Обновить пост
    func updatePost(_ updatedPost: Post) {
        guard var currentProfile = profile else { return }
        
        if let index = currentProfile.posts?.firstIndex(where: { $0.id == updatedPost.id }) {
            currentProfile.posts?[index] = updatedPost
        } else {
            currentProfile.posts?.append(updatedPost)
        }
        
        self.profile = currentProfile
    }
}
