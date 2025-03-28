import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isNavigatingToRegister: Bool = false

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    // MARK: Вход
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            showError = true
            errorMessage = "Заполните все поля"
            return
        }

        AuthService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    AuthService.shared.storeUser(user)
                    print("Успешный вход: \(user)")
                    self.isLoggedIn = true
                case .failure(let error):
                    print("Ошибка входа: \(error)")
                    self.showError = true
                    self.errorMessage = "Ошибка входа: \(error.localizedDescription)"
                }
            }
        }
    }
}
