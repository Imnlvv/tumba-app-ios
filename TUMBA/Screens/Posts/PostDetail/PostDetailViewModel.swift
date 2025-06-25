import Foundation

class PostDetailViewModel: ObservableObject {
    @Published var post: Post
    @Published var isLiked = false
    @Published var currentLike: Like?
    @Published var comments: [Comment] = []
    @Published var newCommentText = ""
    @Published var isLoadingComments = false
    @Published var commentProfiles: [Int: Profile] = [:]
    
    init(post: Post) {
        self.post = post
        checkIfLiked()
        fetchComments()
    }
    
    // MARK: Загрузка профиля
    private func loadProfiles(for comments: [Comment]) {
        comments.forEach { comment in
            if commentProfiles[comment.profileId] == nil {
                ProfileService.shared.fetchProfile(for: comment.profileId) { [weak self] result in
                    if case .success(let profile) = result {
                        DispatchQueue.main.async {
                            self?.commentProfiles[comment.profileId] = profile
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Перезагрузка поста
    func reloadPost() {
        PostService.shared.fetchPost(postId: post.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedPost):
                    self?.post = updatedPost
                    self?.checkIfLiked()
                case .failure(let error):
                    print("Ошибка загрузки поста: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: Загрузка комментариев
    func fetchComments() {
        isLoadingComments = true
        PostService.shared.fetchComments(postId: post.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingComments = false
                switch result {
                case .success(let comments):
                    self?.comments = comments
                    self?.loadProfiles(for: comments)
                case .failure(let error):
                    print("Ошибка загрузки комментариев: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Добавление комментария
    func addComment() {
        guard !newCommentText.isEmpty else { return }
        
        let tempComment = Comment(
            id: Int.random(in: 100_000...999_999),
            body: newCommentText,
            createdAt: Date().iso8601String,
            updatedAt: Date().iso8601String,
            postId: post.id,
            profileId: AuthService.shared.getCurrentUserId() ?? 0
        )
        
        comments.insert(tempComment, at: 0)
        newCommentText = ""
        
        if let profile = AuthService.shared.currentProfile {
            commentProfiles[tempComment.profileId] = profile
        }
        
        PostService.shared.addComment(postId: post.id, body: tempComment.body) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let serverComment):
                    // Заменяем временный комментарий на серверный
                    if let index = self?.comments.firstIndex(where: { $0.id == tempComment.id }) {
                        self?.comments[index] = serverComment
                    }
                    // Добавляем обновление всего списка комментариев
                    self?.fetchComments()
                case .failure(let error):
                    self?.comments.removeAll { $0.id == tempComment.id }
                    self?.newCommentText = tempComment.body
                    print("Ошибка добавления комментария:", error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Удаление комментария
    func deleteComment(commentId: Int) {
        PostService.shared.deleteComment(commentId: commentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Удаляем комментарий из списка
                    self?.comments.removeAll { $0.id == commentId }
                    // Удаляем профиль из кэша, если он есть
                    self?.commentProfiles.removeValue(forKey: commentId)
                case .failure(let error):
                    print("Ошибка удаления комментария:", error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Лайк на пост
    private func checkIfLiked() {
        guard let likes = post.likes,
              let currentUserId = AuthService.shared.getCurrentUserId() else {
            isLiked = false
            currentLike = nil
            return
        }
        // Ищем лайк текущего пользователя для этого поста
        if let like = likes.first(where: { $0.likeableId == post.id && $0.likeableType == "Post" }) {
            isLiked = true
            currentLike = like
        } else {
            isLiked = false
            currentLike = nil
        }
    }
}
