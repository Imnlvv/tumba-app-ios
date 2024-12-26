import Foundation

class TagService {
    static let shared = TagService()

    func fetchTags(completion: @escaping (Result<[Tag], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/api/v1/tags") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode([String: [Tag]].self, from: data)
                if let tags = decodedResponse["tags"] {
                    completion(.success(tags))
                } else {
                    completion(.failure(NSError(domain: "Missing tags key", code: 1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
