import SwiftUI
import PhotosUI

struct EditPostView: View {
    @ObservedObject var viewModel: EditPostViewModel
    @Environment(\.dismiss) var dismiss
    var onUpdate: ((Bool) -> Void)?
    
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 35) {
                    // Редактировать фото
                    imagePickerSection
                    // Редактировать основную часть
                    mainInfoSection
                    // Редактировать теги
                    tagsSection
                    // Кнопка "Редактировать"
                    updatePostButton
                }
                .padding()
            }
            .navigationBarTitle("Редактировать пост", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - func()
    
    // Редактирование изображения
    private var imagePickerSection: some View {
        VStack {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 353, height: 500)
                    .clipped()
            } else if let imageUrl = viewModel.currentImageUrl {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 353, height: 500)
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .frame(width: 353, height: 500)
                }
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 353, height: 500)
            }

            Button("Изменить фото") {
                showImagePicker = true
            }
            .padding(.top, 10)
            .foregroundColor(Color.Custom.gray)
        }
    }
    
    // Редактирование основной части
    private var mainInfoSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Основное".uppercased())
                .font(.system(size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color.Custom.gray)
                .padding(.top, 20)
            
            LabeledTextField(
                label: "Название",
                text: $viewModel.title,
                placeholder: "Новая спальня",
                isSecure: false
            )
            
            LabeledTextField(
                label: "Описание",
                text: $viewModel.description,
                placeholder: "Это моя новая спальня",
                isSecure: false
            )
        }
    }
    
    // Удаление/Добавление тегов
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Теги".uppercased())
                .font(.system(size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color.Custom.gray)
                .padding(.leading, 16)
            
            if !viewModel.selectedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.selectedTags) { tag in
                            HStack(spacing: 15) {
                                Text(tag.name.uppercased())
                                    .font(.system(size: 14))
                                
                                Button(action: {
                                    viewModel.toggleTagSelection(tag)
                                }) {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.Custom.gray, lineWidth: 1)
                            )
                            .foregroundColor(Color.Custom.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(minHeight: 40)
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Искать тег", text: $viewModel.tagSearchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: viewModel.tagSearchText) { newValue in
                        viewModel.searchTags(query: newValue)
                    }
                
                if !viewModel.tagSearchText.isEmpty {
                    Button(action: { viewModel.tagSearchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color.gray.opacity(0.04))
            .padding(.horizontal)
            
            if viewModel.isLoadingTags {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ScrollView {
                    TagFlowLayout(data: viewModel.filteredTags, spacing: 13) { tag in
                        Button(action: {
                            viewModel.toggleTagSelection(tag)
                        }) {
                            Text(tag.name.uppercased())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .font(.system(size: 14))
                                .background(viewModel.selectedTags.contains(where: { $0.id == tag.id }) ? Color.Custom.gray : Color.Custom.gray.opacity(0.06))
                                .foregroundColor(viewModel.selectedTags.contains(where: { $0.id == tag.id }) ? .white : .primary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.top, -375)
                    .padding()
                }
                .background(Color.gray.opacity(0.04))
                .padding(.horizontal)
                .padding(.top, 0)
                .frame(height: 180)
            }
        }
    }
    
    // Кнопка "Обновить пост"
    private var updatePostButton: some View {
        Button(action: {
            viewModel.updatePost { success in
                if success {
                    onUpdate?(true)
                    dismiss()
                }
            }
        }) {
            Text(viewModel.isUpdating ? "Обновление..." : "Сохранить изменения")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isFormValid ? Color.ocean : Color.gray)
                .padding(.horizontal)
        }
        .disabled(!viewModel.isFormValid || viewModel.isUpdating)
        .padding(.top, 20)
    }
}
