import Foundation

class PostService {
    static let shared = PostService()

    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/api/v1/posts") else { return }
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
                let decodedResponse = try JSONDecoder().decode([String: [Post]].self, from: data)
                if let posts = decodedResponse["posts"] {
                    completion(.success(posts))
                } else {
                    completion(.failure(NSError(domain: "Missing posts key", code: 1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
            do {
                let decodedResponse = try JSONDecoder().decode(PostResponse.self, from: data)
                completion(.success(decodedResponse.posts))
            } catch {
                print("Ошибка декодирования постов: \(error)")
                completion(.failure(error))
            }
        }.resume()
    
    }
}
