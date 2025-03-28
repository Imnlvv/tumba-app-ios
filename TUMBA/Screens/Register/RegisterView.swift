import SwiftUI
import PhotosUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RegisterViewModel()
    @StateObject private var mainViewModel = MainViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Spacer()
                // Отображение текущего шага (шаг 1 или шаг 2)
                if viewModel.isStepTwo {
                    stepTwoView
                } else {
                    stepOneView
                }
                Spacer()
                // Нижние кнопки
                bottomButtonsSection
            }
            .padding(.top, 20)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onChange(of: viewModel.isRegistered) { oldValue, newValue in
                if newValue {
                    navigateToMainView()
                }
            }
            .onChange(of: viewModel.selectedImageItem) {
                viewModel.loadImage()
            }
        }
    }

    
    // MARK: - func()
    
    // Этапы регистрации
    // Первый экран (почта + пароль)
    private var stepOneView: some View {
        VStack(spacing: 50) {
            Text("Регистрация")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 25) {
                LabeledTextField(label: "Email", text: $viewModel.email, placeholder: "user@email.com", isSecure: false)
                LabeledTextField(label: "Пароль", text: $viewModel.password, placeholder: "password", isSecure: true)
                LabeledTextField(label: "Подтвердите пароль", text: $viewModel.passwordConfirmation, placeholder: "password", isSecure: true)
            }
            
            if viewModel.showError {
                errorSection
            }
        }
        .padding(.horizontal)
    }
    
    // Второй экран (имя, никнейм, фото)
    private var stepTwoView: some View {
        VStack(spacing: 20) {
            Text("Заполните профиль")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            avatarSection
            
            VStack(spacing: 25) {
                LabeledTextField(label: "Имя", text: $viewModel.name, placeholder: "Иван Иванов", isSecure: false)
                LabeledTextField(label: "Никнейм", text: $viewModel.username, placeholder: "Ivan", isSecure: false)
            }
            
            if viewModel.showError {
                errorSection
            }
        }
        .padding(.horizontal)
    }

    // Аватар
    private var avatarSection: some View {
        PhotosPicker(selection: $viewModel.selectedImageItem, matching: .images) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 170)
                    .clipShape(Rectangle())
            } else {
                ZStack {
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [10]))
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(width: 170, height: 170)

                    Circle()
                        .fill(Color.Custom.gray.opacity(0.5))
                        .frame(width: 40, height: 40)

                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.white)
                }
            }
        }
    }

    // Ошибки заполнения
    private var errorSection: some View {
        Text(viewModel.errorMessage)
            .foregroundColor(.red)
            .font(.footnote)
            .padding()
    }

    // Нижние кнопки
    private var bottomButtonsSection: some View {
        VStack {
            if viewModel.isStepTwo {
                Button(action: { viewModel.isStepTwo = false }) {
                    Text("Назад")
                        .foregroundColor(.ocean)
                        .padding()
                }
            } else {
                Button(action: { dismiss() }) {
                    Text("Отмена")
                        .foregroundColor(.ocean)
                        .padding()
                }
            }
            Button(action: viewModel.nextStep) {
                Text(viewModel.isStepTwo ? "Зарегистрироваться" : "Далее")
                    .fontWeight(.bold)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.ocean)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .opacity(viewModel.isUploading ? 0.7 : 1.0)
            .disabled(viewModel.isUploading)
        }
    }

    // Навигация на MainView
    private func navigateToMainView() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = UIHostingController(rootView: MainView(viewModel: mainViewModel))
            window.makeKeyAndVisible()
        }
    }
}
