import Foundation
class ProfileService {
    static let shared = ProfileService()

    func fetchProfile(for userId: Int, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/api/v1/profiles/\(userId)") else { return }
        
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
                print("Received JSON: \(String(data: data, encoding: .utf8) ?? "No readable data")")
                let decodedResponse = try JSONDecoder().decode(ProfileResponse.self, from: data)
                completion(.success(decodedResponse.profile))
            } catch {
                print("Error decoding Profile: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
