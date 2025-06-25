import Foundation

class ProfileService {
    static let shared = ProfileService()
    
    struct EmptyResponse: Codable {}
    
    struct ProfileResponse: Codable {
        let user: UserProfileResponse
        
        struct UserProfileResponse: Codable {
            let profile: Profile
        }
        
        var profile: Profile {
            return user.profile
        }
    }
    
    // MARK: - Управление профилем
    
    // Загрузка профиля
    func fetchProfile(for userID: Int, completion: @escaping (Result<Profile, Error>) -> Void) {
        let endpoint = "/api/v1/users/\(userID)"
        
        DataLoader.shared.request(endpoint: endpoint, method: "GET") { (result: Result<ProfileResponse, Error>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    completion(.success(response.user.profile))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Подписки
    func followUser(userId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "/api/v1/users/\(userId)/follow"
        let headers = ["Accept": "application/json", "Content-Type": "application/json"]
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "POST",
            headers: headers
        ) { (result: Result<ProfileResponse, Error>) in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Отписки
    func unfollowUser(userId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "/api/v1/users/\(userId)/follow"
        let headers = ["Accept": "application/json"]
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "DELETE",
            headers: headers
        ) { (result: Result<ProfileResponse, Error>) in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // Сохраненные
    func toggleLike(postId: Int, completion: @escaping (Result<Like, Error>) -> Void) {
        let endpoint = "/like/toggle?type=Post&id=\(postId)"
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "POST",
            headers: [
                "Accept": "application/json",
                "Content-Type": "application/json"
            ],
            completion: completion
        )
    }
    
    func fetchFavoritePosts(userId: Int, completion: @escaping (Result<[Post], Error>) -> Void) {
        PostService.shared.fetchPosts { result in
            switch result {
            case .success(let posts):
                let favorites = posts.filter { $0.likes?.contains(where: { $0.likeableType == "Post" }) ?? false }
                completion(.success(favorites))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
