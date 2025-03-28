import Foundation

class TagService {
    static let shared = TagService()
    private init() {}
    
    // MARK: - Управление тегами
    
    // Згрузка тегов из API
    func fetchTags(completion: @escaping (Result<[Tag], Error>) -> Void) {
        DataLoader.shared.request(endpoint: "/tags") { (result: Result<[String: [Tag]], Error>) in
            switch result {
            case .success(let data):
                if let tags = data["tags"] {
                    completion(.success(tags))
                } else {
                    completion(.failure(NSError(domain: "Missing tags key", code: 1, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
