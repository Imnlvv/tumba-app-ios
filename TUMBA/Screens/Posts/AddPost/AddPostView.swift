import SwiftUI
import PhotosUI

struct AddPostView: View {
    @StateObject private var viewModel: AddPostViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showSuccessPopup = false
    
    init(profileId: Int) {
        _viewModel = StateObject(wrappedValue: AddPostViewModel(profileId: profileId))
    }

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 30) {
                        // Загрузка фото
                        imagePickerSection
                        // Основная секция
                        mainInfoSection
                        // Теги
                        tagsSection
                        // Товары
                        productsSection
                        // Кнопка "Создать пост"
                        createPostButton
                    }
                    .padding()
                }
                .navigationBarTitle("Создать пост", displayMode: .inline)
                .sheet(isPresented: $viewModel.showingImagePicker) {
                    ImagePicker(image: $viewModel.selectedImage)
                }
                
                // Кастомное всплывающее окно
                if showSuccessPopup {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {}
                    
                    successPopupView
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                }
            }
        }
    }
    
    // MARK: - func()
    
    // Кастомное всплывающее окно
    private var successPopupView: some View {
        VStack(spacing: 16) {
            
            Text("Поздравляем!")
                .font(.title3)
                .bold()
            
            Text("Пост был успешно создан и опубликован")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: {
                withAnimation {
                    showSuccessPopup = false
                    dismiss()
                }
            }) {
                Text("Отлично")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.ocean)
                    .foregroundColor(.white)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(width: 340)
        .background(Color.white)
    }
    
    // Выбор изображения
    private var imagePickerSection: some View {
        Group {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 353, height: 500)
                    .clipped()
                    .padding()
                    .overlay(alignment: .topTrailing) {
                        Button(action: {
                            withAnimation {
                                viewModel.selectedImage = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 38))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(12)
                        }
                        .offset(x: -16, y: 16)
                    }
            } else {
                Button(action: {
                    viewModel.showingImagePicker = true
                }) {
                    ZStack {
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [10]))
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: 353, height: 500)
                        
                        Circle()
                            .fill(Color.Custom.gray.opacity(0.5))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 20)
            }
        }
    }

    // Текстовая часть подборки
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
    
    // Теги
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
    
    // Товары
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Товары".uppercased())
                .font(.system(size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color.Custom.gray)
                .padding(.top, 20)
            
            VStack(spacing: 10) {
                LabeledTextField(
                    label: "Ссылка на товар",
                    text: .constant(""),
                    placeholder: "https://market.yandex.ru/product...",
                    isSecure: false
                )
                
                Button(action: {}) {
                    Text("Добавить товар")
                        .font(.system(size: 16))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.Custom.lightGray)
                        .foregroundColor(Color.Custom.gray)
                        .cornerRadius(40)
                }
            }
        }
        .padding(.bottom, 20)
    }

    // Кнопка "создать пост"
    private var createPostButton: some View {
        Button(action: {
            viewModel.createPost { success in
                if success {
                    withAnimation {
                        showSuccessPopup = true
                    }
                }
            }
        }) {
            Text(viewModel.isPosting ? "Создание..." : "Создать пост")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isFormValid ? Color.ocean : Color.gray)
                .padding(.horizontal)
        }
        .disabled(!viewModel.isFormValid || viewModel.isPosting)
    }
}

// MARK: - Вспомогательные func()

// TagFlowLayout
struct TagFlowLayout<Content: View, T: Identifiable>: View {
    let data: [T]
    let spacing: CGFloat
    let content: (T) -> Content

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(data) { item in
                content(item)
                    .padding([.horizontal], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > geometry.size.width) {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        width -= d.width + spacing
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item.id == data.last?.id {
                            DispatchQueue.main.async {
                                self.totalHeight = abs(height)
                            }
                        }
                        return result
                    })
            }
        }
    }
}
