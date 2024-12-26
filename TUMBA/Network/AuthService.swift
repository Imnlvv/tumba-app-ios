import Foundation

class AuthService {
    static let shared = AuthService()

    private let userDefaultsKey = "currentUser" // Ключ для сохранения данных

    // Авторизация пользователя
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("Login called with email: \(email), password: \(password)")
        guard let url = URL(string: "http://localhost:3000/api/v1/users/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Параметры запроса
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

        if let body = request.httpBody {
            print("Request body: \(String(data: body, encoding: .utf8) ?? "No readable data")")
        }

        print("Starting login request...")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            // Логируем ответ для отладки
            print("Response: \(String(data: data, encoding: .utf8) ?? "No data")")

            do {
                let response = try JSONDecoder().decode(UserResponse.self, from: data)
                self.saveUser(response.user) // Сохраняем пользователя
                completion(.success(response.user))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    // Сохранить данные пользователя
    func saveUser(_ user: User) { // Убираем private
        if let encodedUser = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedUser, forKey: userDefaultsKey)
            print("User saved to UserDefaults")
        } else {
            print("Failed to encode user")
        }
    }

    // Загрузить данные пользователя
    func loadUser() -> User? {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedUser = try? JSONDecoder().decode(User.self, from: savedData) {
            print("User loaded from UserDefaults")
            return decodedUser
        }
        print("No user found in UserDefaults")
        return nil
    }

    // Удалить данные пользователя (например, при выходе)
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        print("User data cleared from UserDefaults")
    }
    
    static func getCurrentUser() -> User? {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            return user
        }
        return nil
    }
}
