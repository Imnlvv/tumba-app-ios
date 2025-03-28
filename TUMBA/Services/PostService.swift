import Foundation
import UIKit

class PostService {
    static let shared = PostService()
    private init() {}

    // MARK: - Response модели
    private struct UploadResponse: Codable {
        let url: String
    }
    
    // MARK: - Управление постами
    
    // Загрузка постов
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        DataLoader.shared.request(
            endpoint: "/posts",
            method: "GET"
        ) { (result: Result<PostResponse, Error>) in
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

    // Создание поста
    func createPost(
        title: String,
        description: String,
        tags: [String],
        image: UIImage?,
        profileId: Int,
        completion: @escaping (Result<Post, Error>) -> Void
    ) {
        guard let image = image else {
            let error = NSError(domain: "PostService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Изображение обязательно"])
            print("\(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        uploadImage(image: image) { [weak self] result in
            switch result {
            case .success(let imageUrl):
                self?.sendPostRequest(
                    title: title,
                    description: description,
                    tags: tags,
                    imageUrl: imageUrl,
                    profileId: profileId,
                    completion: completion
                )
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // Отправка данных поста
    private func sendPostRequest(
        title: String,
        description: String,
        tags: [String],
        imageUrl: String,
        profileId: Int,
        completion: @escaping (Result<Post, Error>) -> Void
    ) {
        let params: [String: Any] = [
            "post": [
                "title": title,
                "description": description,
                "tag_list": tags,
                "image_url": imageUrl,
                "profile_id": profileId
            ]
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            
            DataLoader.shared.request(
                endpoint: "/posts",
                method: "POST",
                body: jsonData,
                headers: ["Content-Type": "application/json"]
            ) { (result: Result<Post, Error>) in
                switch result {
                case .success(let post):
                    print("Пост успешно создан: \(post.title)")
                    completion(.success(post))
                case .failure(let error):
                    print("Ошибка создания поста: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        } catch {
            print("Ошибка формирования запроса: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    // MARK: - Обработка медиа
    
    // Загрузка изображения
    private func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        DataLoader.shared.multipartRequest(
            endpoint: "/uploads",
            method: "POST",
            parameters: [:],
            image: image,
            imageKey: "file",
            headers: [:]
        ) { (result: Result<UploadResponse, Error>) in
            switch result {
            case .success(let response):
                print("Изображение загружено: \(response.url)")
                completion(.success(response.url))
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - Управление профилем
    
    // Получение текущего пользователя
    func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        DataLoader.shared.request(
            endpoint: "/users/me",
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
}
