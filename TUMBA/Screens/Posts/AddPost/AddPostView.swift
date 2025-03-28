import SwiftUI
import PhotosUI

struct AddPostView: View {
    @StateObject private var viewModel: AddPostViewModel

    init(profileId: Int) {
        _viewModel = StateObject(wrappedValue: AddPostViewModel(profileId: profileId))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    imagePickerSection
                    mainInfoSection
                    tagsSection
                    productsSection
                    createPostButton
                }
                .padding()
            }
            .navigationBarTitle("Создать пост", displayMode: .inline)
        }
    }
    
    // MARK: - func()

    // Выбор изображения
    private var imagePickerSection: some View {
        Group {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 170)
                    .padding()
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
                .onTapGesture {
                    viewModel.showingImagePicker = true
                }
                .padding(.top, 20)
            }
        }
    }

    // Основная информация
    private var mainInfoSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Основное".uppercased())
                .font(.system(size: 20))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray)
                .padding(EdgeInsets(top: 40, leading: 0, bottom: 15, trailing: 0))

            LabeledTextField(label: "Название", text: $viewModel.title, placeholder: "Новая спальня", isSecure: false)
            LabeledTextField(label: "Описание", text: $viewModel.description, placeholder: "Это моя новая спальня", isSecure: false)
        }
    }

    // Теги
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Теги".uppercased())
                .font(.system(size: 20))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray)
                .padding(EdgeInsets(top: 40, leading: 0, bottom: 15, trailing: 0))

            LabeledTextField(label: "Теги (через запятую)", text: $viewModel.tags, placeholder: "Комфорт, минимализм", isSecure: false)
        }
    }

    // Товары
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Товары".uppercased())
                .font(.system(size: 20))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray)
                .padding(EdgeInsets(top: 40, leading: 0, bottom: 15, trailing: 0))

            VStack {
                LabeledTextField(label: "Добавить товар", text: $viewModel.tags, placeholder: "https://market.yandex.ru/product..", isSecure: false)

                Button(action: {}) {
                    Text("Найти")
                        .font(.system(size: 16))
                        .fontWeight(.regular)
                        .foregroundColor(Color.Custom.gray)
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .background(Color.Custom.lightGray)
                .cornerRadius(40)
            }
        }
        .padding(.bottom, 40)
    }

    // Кнопка создания поста
    private var createPostButton: some View {
        Button(viewModel.isPosting ? "Создание..." : "Создать пост") {
            viewModel.createPost()
        }
        .disabled(viewModel.title.isEmpty || viewModel.description.isEmpty || viewModel.selectedImage == nil || viewModel.isPosting || viewModel.profileId == 0)
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
