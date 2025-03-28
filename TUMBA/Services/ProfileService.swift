import Foundation

class ProfileService {
    static let shared = ProfileService()
    
    private struct ProfileResponse: Codable {
        let profile: Profile
    }
    
    // MARK: - Управление профилем
    
    // Загрузка профиля
    func fetchProfile(for userID: Int, completion: @escaping (Result<Profile, Error>) -> Void) {
        let endpoint = "/users/\(userID)"
        let headers = ["Accept": "application/json"]
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "GET",
            headers: headers
        ) { (result: Result<ProfileResponse, Error>) in
            switch result {
            case .success(let response):
                let profile = response.profile
                print("Профиль загружен: \(profile.username)")
                completion(.success(profile))
                
            case .failure(let error):
                print("Ошибка загрузки профиля: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
