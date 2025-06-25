import Foundation
import UIKit

class PostService {
    static let shared = PostService()
    private init() {}
    private var cachedItems: [Int: [Item]] = [:]
    
    // MARK: - Управление постами
    
    // Создать пост
    func createPost(
        title: String,
        description: String,
        tags: [String],
        image: UIImage,
        profileId: Int,
        completion: @escaping (Result<Post, Error>) -> Void
    ) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        // Текстовые параметры (кроме тегов)
        let textParams: [String: String] = [
            "post[title]": title,
            "post[description]": description,
            "post[public]": "true"
        ]
        
        // Добавляем текстовые поля
        for (key, value) in textParams {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Добавляем теги (каждый тег отдельно)
        for tag in tags {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"post[tag_list][]\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(tag)\r\n".data(using: .utf8)!)
        }
        
        // Добавляем изображение
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"post[image_url]\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var headers = [
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
            "Accept": "application/json"
        ]
        
        if let token = AuthService.shared.loadToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        DataLoader.shared.uploadRequest(
            endpoint: "/api/v1/posts",
            method: "POST",
            body: body,
            headers: headers
        ) { (result: Result<PostResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.post))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Прогрузка поста/постов
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        DataLoader.shared.request(
            endpoint: "/api/v1/posts",
            method: "GET"
        ) { (result: Result<PostsResponse, Error>) in
            switch result {
            case .success(let response):
                print("Успешно загружено \(response.posts.count) постов")
                completion(.success(response.posts))
            case .failure(let error):
                print("Ошибка загрузки постов: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func fetchPost(postId: Int, completion: @escaping (Result<Post, Error>) -> Void) {
        DataLoader.shared.request(
            endpoint: "/api/v1/posts/\(postId)",
            method: "GET"
        ) { (result: Result<PostResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.post))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Удаление поста
    func deletePost(postId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Попытка удалить пост с идентификатором: \(postId)")
        
        var headers = [
            "Accept": "application/json"
        ]
        
        if let token = AuthService.shared.loadToken() {
            headers["Authorization"] = "Bearer \(token)"
            print("Добавлен токен авторизации")
        } else {
            print("Токен авторизации не найден")
        }
        
        DataLoader.shared.request(
            endpoint: "/api/v1/posts/\(postId)",
            method: "DELETE",
            headers: headers
        ) { (result: Result<Void, Error>) in
            switch result {
            case .success:
                print("Пост успешно удален на сервере")
                completion(.success(()))
            case .failure(let error):
                print("Не удалось удалить пост: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // Обновление поста
    func updatePost(
        postId: Int,
        title: String,
        description: String,
        tags: [String],
        image: UIImage?,
        completion: @escaping (Result<Post, Error>) -> Void
    ) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        // Текстовые параметры
        let textParams: [String: String] = [
            "post[title]": title,
            "post[description]": description,
            "post[public]": "true"
        ]
        
        for (key, value) in textParams {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Теги
        for tag in tags {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"post[tag_list][]\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(tag)\r\n".data(using: .utf8)!)
        }
        
        // Изображение (если есть)
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"post[image_url]\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var headers = [
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
            "Accept": "application/json"
        ]
        
        if let token = AuthService.shared.loadToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        DataLoader.shared.uploadRequest(
            endpoint: "/api/v1/posts/\(postId)",
            method: "PATCH",
            body: body,
            headers: headers
        ) { (result: Result<PostResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.post))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Управление профилем

    // Прогрузка текущего профиля
    func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        DataLoader.shared.request(
            endpoint: "/api/v1/users/me",
            method: "GET",
            headers: ["Content-Type": "application/json"]
        ) { (result: Result<User, Error>) in
            switch result {
            case .success(let user):
                print("Текущий пользователь получен")
                completion(.success(user))
            case .failure(let error):
                print("Ошибка получения пользователя")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Управление комментариями

    // Прогрузка комментариев
    func fetchComments(postId: Int, completion: @escaping (Result<[Comment], Error>) -> Void) {
        let endpoint = "/api/v1/comments?post_id=\(postId)"
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "GET"
        ) { (result: Result<CommentResponse, Error>) in
            switch result {
            case .success(let response):
                 completion(.success(response.comments))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Добавление комментария
    func addComment(postId: Int, body: String, completion: @escaping (Result<Comment, Error>) -> Void) {
        let endpoint = "/api/v1/comments"
        
        guard let authToken = AuthService.shared.loadToken() else {
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let parameters: [String: Any] = [
            "comment": [
                "body": body,
                "post_id": postId
            ]
        ]
        
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(authToken)"
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: parameters) else {
            completion(.failure(NSError(domain: "EncodingError", code: -1, userInfo: nil)))
            return
        }
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "POST",
            body: bodyData,
            headers: headers
        ) { (result: Result<SingleCommentResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(.success(response.comment))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Удаление комментария
    func deleteComment(commentId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "/api/v1/comments/\(commentId)"
        
        var headers = [
            "Accept": "application/json"
        ]
        
        if let token = AuthService.shared.loadToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "DELETE",
            headers: headers
        ) { (result: Result<Void, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
