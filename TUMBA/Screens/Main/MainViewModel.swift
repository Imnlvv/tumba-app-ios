import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var currentUserProfile: Profile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: Прогрузка профиля
    func loadUserProfile() {
        isLoading = true
        errorMessage = nil

        AuthService.shared.fetchCurrentUserProfile { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let profile):
                    self.currentUserProfile = profile
                    print("Профиль загружен: \(profile.username)")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Ошибка загрузки профиля: \(error.localizedDescription)")
                }
            }
        }
    }
}
