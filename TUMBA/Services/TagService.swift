import Foundation

class TagService {
    static let shared = TagService()
    private init() {}
    
    // MARK: - Управление тегами
    
    // Згрузка тегов из API
    func fetchTags(completion: @escaping (Result<[Tag], Error>) -> Void) {
        DataLoader.shared.request(endpoint: "/api/v1/tags") { (result: Result<[String: [Tag]], Error>) in
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
    
    // Загрузка всех тегов с возможностью фильтрации
    func fetchTags(searchQuery: String? = nil, completion: @escaping (Result<[Tag], Error>) -> Void) {
        var endpoint = "/api/v1/tags"
        if let query = searchQuery, !query.isEmpty {
            endpoint += "?search=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        DataLoader.shared.request(endpoint: endpoint) { (result: Result<[String: [Tag]], Error>) in
            switch result {
            case .success(let data):
                if let tags = data["tags"] {
                    completion(.success(tags))
                } else {
                    completion(.failure(NSError(domain: "TagService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Загрузка популярных тегов (если нужно)
    func fetchPopularTags(limit: Int = 10, completion: @escaping (Result<[Tag], Error>) -> Void) {
        DataLoader.shared.request(endpoint: "/api/v1/tags/popular?limit=\(limit)") { (result: Result<[String: [Tag]], Error>) in
            switch result {
            case .success(let data):
                completion(.success(data["tags"] ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
