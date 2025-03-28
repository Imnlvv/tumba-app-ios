import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var mainViewModel = MainViewModel()

    var body: some View {
        NavigationStack {
            if viewModel.isLoggedIn {
                MainView(viewModel: mainViewModel)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    // Основной контент
                    loginContentSection
                    Spacer()
                    // Кнопка входа
                    loginButtonSection
                    // Отображение ошибки
                    if viewModel.showError {
                        errorSection
                    }
                }
                .padding(.vertical, 20)
                .ignoresSafeArea(.all, edges: .top)
                .onAppear {
                    checkIfUserIsLoggedIn()
                }
                .navigationDestination(isPresented: $viewModel.isNavigatingToRegister) {
                    RegisterView()
                }
            }
        }
    }
    
    // MARK: - func()

    // Основной контент (заголовок, поля ввода, ссылка на регистрацию)
    private var loginContentSection: some View {
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
            
            // Поля ввода
            VStack(spacing: 20) {
                VStack(spacing: 27) {
                    LabeledTextField(label: "Email", text: $viewModel.email, placeholder: "user@email.com", isSecure: false)
                    
                    LabeledTextField(label: "Пароль", text: $viewModel.password, placeholder: "password1234", isSecure: true)
                }
                
                // Ссылка на регистрацию
                Button(action: { viewModel.isNavigatingToRegister = true }) {
                    Text("Нет аккаунта? Зарегистрироваться")
                        .foregroundColor(.ocean)
                        .font(.footnote)
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal)
    }

    // Кнопка входа
    private var loginButtonSection: some View {
        Button(action: viewModel.login) {
            Text("Войти")
                .fontWeight(.bold)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.ocean)
                .foregroundColor(.white)
                .padding(.horizontal)
                .opacity(viewModel.email.isEmpty || viewModel.password.isEmpty ? 0.7 : 1.0)
        }
        .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
    }

    // Ошибка входа
    private var errorSection: some View {
        Text(viewModel.errorMessage)
            .foregroundColor(.red)
            .font(.footnote)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    // Проверка, авторизован ли пользователь
    private func checkIfUserIsLoggedIn() {
        if let _ = AuthService.shared.loadUser() {
            viewModel.isLoggedIn = true
        }
    }
}
