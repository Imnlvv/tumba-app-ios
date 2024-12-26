import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoggedIn: Bool = false

    var body: some View {
        if isLoggedIn {
            MainView() // Переход на главный экран после авторизации
        } else {
            VStack(spacing: 20) {
                Spacer()
                VStack(spacing: 50) {
                    // Заголовок
                    Text("Вход")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("С возвращением, мы скучали!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 200)

                    VStack(spacing: 20) {
                        VStack(spacing: 0) {
                            Text("Email")
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 7)
                                .background(Color.carrot)
                                .frame(maxWidth: .infinity, alignment: .leading) // Выровнять по левому краю
                            TextField("user@email. com", text: $email) // Изменить плейсхолдер
                                .padding(24)
                                .background(Color.dust)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }

                        VStack(spacing: 0) {
                            Text("Пароль")
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 7)
                                .background(Color.carrot)
                                .frame(maxWidth: .infinity, alignment: .leading) // Выровнять по левому краю
                            SecureField("password123", text: $password)
                                .padding(24)
                                .background(Color.dust)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                Button(action: login) {
                    Text("Войти")
                        .fontWeight(.bold)
                        .padding(.vertical, 16) // Увеличенный вертикальный паддинг
                        .frame(maxWidth: .infinity)
                        .background(Color.ocean)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .opacity(email.isEmpty || password.isEmpty ? 0.7 : 1.0) // Полупрозрачность
                }
                .disabled(email.isEmpty || password.isEmpty) // Отключаем кнопку, если поля пустые

                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .frame(maxHeight: .infinity) // Заполнение пространства
            .padding(.horizontal)
            .padding(.vertical, 20) // Отступы сверху и снизу
            .onAppear {
                if let _ = AuthService.shared.loadUser() {
                    isLoggedIn = true // Если пользователь сохранен, логин не требуется
                }
            }
        }
    }

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
                    AuthService.shared.saveUser(user) // Сохраняем пользователя
                    print("Login successful for user: \(user)")
                    isLoggedIn = true
                case .failure(let error):
                    print("Login failed with error: \(error)")
                    showError = true
                    errorMessage = "Ошибка входа: \(error.localizedDescription)"
                }
            }
        }
    }
}
