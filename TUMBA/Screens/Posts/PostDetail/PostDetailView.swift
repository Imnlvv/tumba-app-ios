import SwiftUI

struct PostDetailView: View {
    @StateObject private var viewModel: PostDetailViewModel
    @State private var showingDeleteAlert = false
    @State private var showEditView = false
    @Environment(\.dismiss) var dismiss
    
    init(post: Post) {
        _viewModel = StateObject(wrappedValue: PostDetailViewModel(post: post))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Фото поста
                postImageSection
                // Основная часть поста
                postContentSection
                // Товары
                itemsSection
                // Комментарии
                сommentSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Удалить пост?", isPresented: $showingDeleteAlert) {
            Button("Удалить", role: .destructive) {
                deletePost()
            }
            Button("Отмена", role: .cancel) {}
        }
        .sheet(isPresented: $showEditView) {
            EditPostView(viewModel: EditPostViewModel(post: viewModel.post)) { success in
                if success {
                    viewModel.reloadPost()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .postDeleted)) { notification in
            if let postId = notification.object as? Int, postId == viewModel.post.id {
                dismiss()
            }
        }
        .onAppear {
            viewModel.fetchComments()
        }
    }
    
    // MARK: - func()

    // Проверка текущего пользователя (редактировать, удалить пост)
    private var isCurrentUserPost: Bool {
        guard let currentUserId = AuthService.shared.getCurrentUserId(),
              let postAuthorId = viewModel.post.profile?.id else {
            return false
        }
        return currentUserId == postAuthorId
    }
    
    // Фото поста
    private var postImageSection: some View {
        AsyncImage(url: imageURLWithBypass) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: 353, height: 500)
                .clipped()
        } placeholder: {
            Color.gray.opacity(0.3)
                .frame(width: 353, height: 500)
        }
    }
    
    private var imageURLWithBypass: URL? {
        guard let urlString = viewModel.post.imageUrl?.fullUrl else { return nil }
        return URL(string: "\(urlString)?cache_bust=\(UUID().uuidString)")
    }
    
    // Основной контент поста
    private var postContentSection: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(formattedDate(from: viewModel.post.createdAt ?? ""))
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray.opacity(0.5))
            
            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.post.title.uppercased())
                    .font(.system(size: 23))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.Custom.gray)
                
                Text(viewModel.post.description)
                    .font(.body)
                    .fontWeight(.regular)
            }
            
            tagsSection
            HStack {
                userInfoSection
                Spacer()
                interactionSection
            }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
        .frame(maxWidth: 353, maxHeight: .infinity)
    }
    
    // Теги
    private var tagsSection: some View {
        Group {
            if !viewModel.post.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.post.tags, id: \.self) { tag in
                            Text(tag.capitalized.uppercased())
                                .padding(.horizontal, 12)
                                .font(.system(size: 14))
                                .frame(height: 30)
                                .foregroundColor(.white)
                                .background(Color.Custom.gray)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
    
    // О пользователе
    private var userInfoSection: some View {
        NavigationLink {
            if let userId = viewModel.post.profile?.id {
                ProfileView(userId: userId)
            }
        } label: {
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: viewModel.post.profile?.fullAvatarUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                }
                
                Text("\(viewModel.post.profile?.username ?? "username")")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.Custom.gray)
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .background(Color.Custom.lightGray)
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    
    // Альтернативный аватар
    private var placeholderAvatar: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 40, height: 40)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
            )
    }
    
    // Взаимодействия с постом
    private var interactionSection: some View {
        HStack(spacing: 20) {
            Image("like_icon")
            
            Button(action: sharePost) {
                Image("share_icon")
            }
            
            if isCurrentUserPost {
                Menu {
                    Button(action: {
                        showEditView = true
                    }) {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Удалить", systemImage: "trash")
                    }
                } label: {
                    Image("more_icon")
                }
            }
        }
    }
    
    // Товары
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Товары".uppercased())
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 23))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray)
                .padding(.leading, 26)
            
            if let items = viewModel.post.items, !items.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 50) {
                    ForEach(items) { item in
                        ItemCardView(item: item)
                            .frame(minHeight: 250)
                            .alignmentGuide(.top) { _ in 0 }
                    }
                }
                .padding(.horizontal, 26)
            } else {
                Text("Автор не добавил товаров")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.leading, 26)
                    .padding(.bottom, 40)
            }
        }
    }

    // Комментарии
    private var сommentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Text("Комментарии".uppercased())
                    .font(.system(size: 23))
                    .fontWeight(.regular)
                    .foregroundColor(Color.Custom.gray)
                    .padding(.leading, 26)
                
                Text("\(viewModel.comments.count)")
                    .font(.system(size: 20))
                    .fontWeight(.regular)
                    .foregroundColor(Color.Custom.gray.opacity(0.5))
                
                Spacer()
            }
            .padding(.trailing, 26)

            if viewModel.isLoadingComments {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.comments.isEmpty {
                Text("Пока нет комментариев")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.leading, 26)
                    .padding(.bottom, 40)
            } else {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.comments) { comment in
                        CommentView(
                            comment: comment,
                            profile: viewModel.commentProfiles[comment.profileId] ?? nil,
                            onDelete: {
                                viewModel.deleteComment(commentId: comment.id)
                            }
                        )
                        .padding(.horizontal, 15)
                    }
                }
            }
            commentInputSection
        }
        .padding(.top, 25)
    }
    
    // Введение комментария
    private var commentInputSection: some View {
        HStack(alignment: .center, spacing: 12) {
            if let profile = AuthService.shared.currentProfile {
                AsyncImage(url: URL(string: profile.fullAvatarUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    case .failure:
                        placeholderAvatar
                    case .empty:
                        ProgressView()
                            .frame(width: 40, height: 40)
                    @unknown default:
                        placeholderAvatar
                    }
                }
            } else {
                placeholderAvatar
            }

            HStack(spacing: 8) {
                TextField("Написать комментарий...", text: $viewModel.newCommentText)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.Custom.lightGray.opacity(0.8))
                    .cornerRadius(20)
                
                Button(action: {
                    if !viewModel.newCommentText.isEmpty {
                        viewModel.addComment()
                    }
                }) {
                    Image("paperplane_icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(viewModel.newCommentText.isEmpty ? Color.gray.opacity(0.5) : Color.gray)
                        .clipShape(Circle())
                }
                .disabled(viewModel.newCommentText.isEmpty)
            }
        }
        .padding(.horizontal, 26)
        .padding(.bottom, 40)
    }

    // Форматер даты (в тип "13 июня, 2024")
    private func formattedDate(from isoDate: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        let outputFormatter = DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        outputFormatter.dateFormat = "d MMMM, yyyy"
        outputFormatter.locale = Locale(identifier: "ru_RU")

        return dateFormatter.date(from: isoDate)
            .map { outputFormatter.string(from: $0) } ?? "Неизвестная дата"
    }
    
    // Функция шеринга
    private func sharePost() {
        let shareText = """
        \(viewModel.post.title.uppercased())
        \(viewModel.post.description)
        """
        
        if let imageUrl = viewModel.post.imageUrl?.fullUrl,
           let url = URL(string: imageUrl) {
            
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                activityIndicator.center = rootVC.view.center
                rootVC.view.addSubview(activityIndicator)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url),
                   let image = UIImage(data: imageData) {
                    
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        
                        var shareItems: [Any] = [shareText, image]
                        
                        if let postUrl = URL(string: "https://вашсайт.com/posts/\(viewModel.post.id)") {
                            shareItems.append(postUrl)
                        }
                        
                        self.presentShareController(with: shareItems)
                    }
                } else {
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        self.presentShareController(with: [shareText])
                    }
                }
            }
        } else {
            presentShareController(with: [shareText])
        }
    }

    private func presentShareController(with items: [Any]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .saveToCameraRoll
        ]
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }
        
        rootVC.present(activityVC, animated: true)
    }
    
    // Удалить пост
    private func deletePost() {
        PostService.shared.deletePost(postId: viewModel.post.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    NotificationCenter.default.post(name: .postDeleted, object: viewModel.post.id)
                    dismiss()
                case .failure(let error):
                    print("Ошибка удаления поста: \(error.localizedDescription)")
                }
            }
        }
    }
}
