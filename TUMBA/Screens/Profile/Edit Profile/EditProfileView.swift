import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @StateObject private var viewModel: EditProfileViewModel
    
    init(name: String, username: String, onSave: @escaping (String, String, UIImage?) -> Void) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(
            name: name,
            username: username,
            onSave: onSave
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    avatarSection
                    mainInfoSection
                    saveButton
                }
                .padding()
            }
            .navigationBarTitle("Редактировать профиль", displayMode: .inline)
        }
    }
    
    // MARK: - func()
    
    // Аватар
    private var avatarSection: some View {
        Group {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 170)
                    .clipShape(Circle())
                    .padding()
            } else {
                PhotosPicker(selection: $viewModel.selectedImageItem, matching: .images) {
                    ZStack {
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [10]))
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: 170, height: 170)
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                .onChange(of: viewModel.selectedImageItem) { _ in
                    Task {
                        if let data = try? await viewModel.selectedImageItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel.selectedImage = image
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
    }
    
    // Основная информация
    private var mainInfoSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Основная информация".uppercased())
                .font(.system(size: 20))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray)
                .padding(EdgeInsets(top: 40, leading: 0, bottom: 15, trailing: 0))
            
            LabeledTextField(label: "Имя", text: $viewModel.name, placeholder: "Иван Иванов", isSecure: false)
            LabeledTextField(label: "Никнейм", text: $viewModel.username, placeholder: "ivan", isSecure: false)
        }
    }
    
    // Кнопка сохранения
    private var saveButton: some View {
        Button(viewModel.isSaving ? "Сохранение..." : "Сохранить изменения") {
            viewModel.saveChanges()
        }
        .disabled(viewModel.name.isEmpty || viewModel.username.isEmpty || viewModel.isSaving)
        .padding()
        .font(.headline)
        .fontWeight(.bold)
        .padding(.vertical, 1)
        .frame(maxWidth: .infinity)
        .background(Color.ocean)
        .foregroundColor(.white)
        .padding(.horizontal)
    }
}
