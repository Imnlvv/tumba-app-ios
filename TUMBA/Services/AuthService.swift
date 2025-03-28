import Foundation
import UIKit

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // MARK: - Конфигурация Keychain
    private struct KeychainConfig {
        static let service = Bundle.main.bundleIdentifier ?? "com.your.app"
        static let tokenAccount = "authToken"
        static let userAccount = "currentUser"
    }
    
    // MARK: - Сетевые запросы
    
    // MARK: Аутентификация
    
    // Вход
    func login(email: String, password: String, completion: @escaping (Result<UserWithProfile, Error>) -> Void) {
        print("Вход: \(email)")
        
        let endpoint = "/sign_in"
        let body: [String: Any] = ["user": ["email": email, "password": password]]
        let headers = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            
            DataLoader.shared.request(
                endpoint: endpoint,
                method: "POST",
                body: jsonData,
                headers: headers
            ) { (result: Result<AuthResponse, Error>) in
                switch result {
                case .success(let response):
                    self.storeUser(response.user)
                    self.storeToken(response.jwt)
                    print("Успешный вход.Токен сохранен.")
                    completion(.success(response.user))
                    
                case .failure(let error):
                    print("Ошибка входа: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    // Регистрация (этап 1)
    func register(
        name: String,
        username: String,
        email: String,
        password: String,
        passwordConfirmation: String,
        completion: @escaping (Result<AuthResponse, Error>) -> Void
    ) {
        print("Регистрация: \(email), username: \(username)")
        
        let endpoint = "/sign_up"
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let user: [String: Any] = [
            "email": email,
            "password": password,
            "password_confirmation": passwordConfirmation
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["user": user], options: [])
            
            DataLoader.shared.request(
                endpoint: endpoint,
                method: "POST",
                body: jsonData,
                headers: headers
            ) { (result: Result<AuthResponse, Error>) in
                switch result {
                case .success(let response):
                    self.storeToken(response.jwt)
                    print("Успешная регистрация.Токен сохранен.")
                    completion(.success(response))
                    
                case .failure(let error):
                    print("Ошибка регистрации: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        } catch {
            print("Ошибка JSON: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    // Регистрация (этап 2)
    func registerUser(
        name: String,
        username: String,
        email: String,
        password: String,
        passwordConfirmation: String,
        completion: @escaping (Result<UserWithProfile, Error>) -> Void
    ) {
        let endpoint = "/sign_up"
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let user: [String: Any] = [
            "email": email,
            "password": password,
            "password_confirmation": passwordConfirmation
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["user": user], options: .prettyPrinted)
            
            // Логируем отправляемые данные (как в оригинале)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Отправляем JSON:\n\(jsonString)")
            }
            
            DataLoader.shared.request(
                endpoint: endpoint,
                method: "POST",
                body: jsonData,
                headers: headers
            ) { (result: Result<AuthResponse, Error>) in
                switch result {
                case .success(let response):
                    // Проверяем статус-код через response
                    print("Регистрация успешна. Код: 201")
                    completion(.success(response.user))
                    
                case .failure(let error):
                    // Обрабатываем ошибки (включая кастомные от сервера)
                    if let serverError = error as? NSError,
                       let errorData = serverError.userInfo["data"] as? Data,
                       let jsonResponse = try? JSONSerialization.jsonObject(with: errorData) as? [String: Any] {
                        let errorMessage = jsonResponse["errors"] as? [String] ?? ["Неизвестная ошибка"]
                        print("Ошибки регистрации: \(errorMessage)")
                    }
                    completion(.failure(error))
                }
            }
        } catch {
            print("Ошибка сериализации JSON: \(error)")
            completion(.failure(error))
        }
    }

    // Выход
    func logout(completion: @escaping (Bool) -> Void) {
        guard let token = loadToken() else {
            print("Ошибка выхода: токен не найден")
            completion(false)
            return
        }
        
        print("Используемый токен: \(token)")
        
        let endpoint = "/sign_out"
        let headers = [
            "Accept": "application/json",
            "Authorization": token
        ]
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "POST",
            headers: headers
        ) { (result: Result<Void, Error>) in
            switch result {
            case .success:
                // Удаляем токен и пользователя
                self.removeToken()
                self.storeUser(nil)
                UserDefaults.standard.set(true, forKey: "isOnboardingShown")
                
                print("Выход выполнен успешно")
                completion(true)
                
            case .failure(let error):
                print("Ошибка выхода: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    // Удаление
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        guard let token = loadToken() else {
            print("Ошибка: Не удалось получить токен для удаления аккаунта")
            completion(false)
            return
        }

        let endpoint = "/delete_account"
        let headers = [
            "Accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]

        DataLoader.shared.request(
            endpoint: endpoint,
            method: "DELETE",
            headers: headers
        ) { (result: Result<Void, Error>) in
            switch result {
            case .success:
                // Успешное удаление - очищаем данные
                self.removeToken()
                self.storeUser(nil)
                print("Аккаунт успешно удалён")
                completion(true)
                
            case .failure(let error):
                print("Ошибка удаления аккаунта: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    // MARK: Управление профилем
    
    // Загрузка текущего профиля
    func fetchCurrentUserProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let token = loadToken() else {
            completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token not found"])))
            return
        }
        
        let endpoint = "/me/profile"
        let headers = [
            "Accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "GET",
            headers: headers
        ) { (result: Result<ProfileResponse, Error>) in
            switch result {
            case .success(let response):
                var profile = response.profile
                
                // Обновляем посты с профилем (если есть)
                if var posts = profile.posts {
                    for i in posts.indices {
                        posts[i].profile = profile
                    }
                    profile.posts = posts
                }
                
                print("Профиль загружен: \(profile.username)")
                completion(.success(profile))
                
            case .failure(let error):
                print("Профиль не найден: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // Запрос профиля пользователя после регистрации
    func fetchUserProfile(profileId: Int, completion: @escaping (Result<UserWithProfile, Error>) -> Void) {
        let endpoint = "/profiles/\(profileId)"
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "GET"
        ) { (result: Result<ProfileResponse, Error>) in
            switch result {
            case .success(let response):
                let profile = response.profile
                let userWithProfile = UserWithProfile(
                    id: profileId,
                    email: "",
                    profile: profile
                )
                
                self.storeUser(userWithProfile)
                print("Профиль пользователя \(profile.username) успешно загружен")
                completion(.success(userWithProfile))
                
            case .failure(let error):
                print("Ошибка загрузки профиля: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // Перезапись профиля при регистрации
    func updateProfile(
        profileId: Int,
        name: String,
        username: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        guard let token = loadToken() else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token not found"])))
            return
        }
        
        let endpoint = "/profiles/\(profileId)"
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        let body: [String: Any] = [
            "profile": [
                "name": name,
                "username": username
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            
            DataLoader.shared.request(
                endpoint: endpoint,
                method: "PATCH",
                body: jsonData,
                headers: headers
            ) { (result: Result<ProfileResponse, Error>) in
                switch result {
                case .success(let response):
                    print("Профиль успешно обновлен")
                    completion(.success(response.profile))
                    
                case .failure(let error):
                    print("Ошибка обновления: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // Перезапись профиля при регистрации (фото)
    func updateProfileWithAvatar(
        profileId: Int,
        name: String,
        username: String,
        image: UIImage,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        guard let token = loadToken() else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token not found"])))
            return
        }
        
        let endpoint = "/profiles/\(profileId)"
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters = [
            "profile[name]": name,
            "profile[username]": username
        ]
        
        DataLoader.shared.multipartRequest(
            endpoint: endpoint,
            method: "PATCH",
            parameters: parameters,
            image: image,
            imageKey: "profile[avatar_url]",
            headers: headers
        ) { (result: Result<ProfileResponse, Error>) in
            switch result {
            case .success(let response):
                print("Профиль с аватаром успешно обновлен")
                completion(.success(response.profile))
                
            case .failure(let error):
                print("Ошибка обновления с аватаром: \(error.localizedDescription)")
                if let data = (error as NSError).userInfo["data"] as? Data {
                    print("Подробности: \(String(data: data, encoding: .utf8) ?? "")")
                }
                completion(.failure(error))
            }
        }
    }
    
    // Обновление аватара профиля
    func uploadAvatar(image: UIImage, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let profileId = loadUser()?.profile?.id,
              let token = loadToken() else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Необходима авторизация"])))
            return
        }
        
        let endpoint = "/profiles/\(profileId)"
        let headers = ["Authorization": "Bearer \(token)"]
        
        DataLoader.shared.multipartRequest(
            endpoint: endpoint,
            method: "PATCH",
            parameters: [:],
            image: image,
            imageKey: "profile[avatar_url]",
            headers: headers
        ) { (result: Result<ProfileResponse, Error>) in
            switch result {
            case .success(let response):
                print("Аватар успешно загружен")
                completion(.success(response.profile))
                
            case .failure(let error):
                print("Ошибка загрузки аватара: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // Обновление профиля
    func updateProfile(
        name: String,
        username: String,
        avatarUrl: String?,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        guard let profileId = loadUser()?.profile?.id,
              let token = loadToken() else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Необходима авторизация"])))
            return
        }
        
        let endpoint = "/profiles/\(profileId)"
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        var profileData: [String: Any] = [
            "name": name,
            "username": username
        ]
        
        if let avatarUrl = avatarUrl {
            profileData["avatar_url"] = avatarUrl
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["profile": profileData], options: [])
            
            DataLoader.shared.request(
                endpoint: endpoint,
                method: "PATCH",
                body: jsonData,
                headers: headers,
                completion: completion
            )
        } catch {
            print("Ошибка формирования запроса: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Управление токенами
    
    // Получение CSRF-токена
    func fetchCSRFToken(completion: @escaping (String?) -> Void) {
        let endpoint = "/"
        
        DataLoader.shared.request(
            endpoint: endpoint,
            method: "GET"
        ) { (result: Result<Void, Error>) in
            switch result {
            case .success:
                if let response = (result as? Result<HTTPURLResponse, Error>),
                   case let .success(httpResponse) = response {
                    let csrfToken = httpResponse.allHeaderFields["X-CSRF-Token"] as? String
                    print("Получен CSRF-токен: \(csrfToken?.prefix(8) ?? "nil")...")
                    completion(csrfToken)
                } else {
                    print("CSRF-токен не найден в заголовках")
                    completion(nil)
                }
                
            case .failure(let error):
                print("Ошибка получения CSRF-токена: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // Работа с JWT-токеном
    private func storeToken(_ token: String) {
        let success = KeychainHelper.shared.save(
            token,
            service: KeychainConfig.service,
            account: KeychainConfig.tokenAccount
        )
        print(success ? "Токен сохранён в Keychain" : "Ошибка сохранения токена")
    }

    func loadToken() -> String? {
        return KeychainHelper.shared.read(
            service: KeychainConfig.service,
            account: KeychainConfig.tokenAccount,
            type: String.self
        )
    }

    func removeToken() {
        let success = KeychainHelper.shared.delete(
            service: KeychainConfig.service,
            account: KeychainConfig.tokenAccount
        )
        print(success ? "Токен удалён из Keychain" : "Ошибка удаления токена")
    }
    
    // MARK: - Управление сеансами пользователей
    
    // Сохранение
    func storeUser(_ user: UserWithProfile?) {
        guard let user = user else {
            KeychainHelper.shared.delete(
                service: KeychainConfig.service,
                account: KeychainConfig.userAccount
            )
            return
        }
        
        let success = KeychainHelper.shared.save(
            user,
            service: KeychainConfig.service,
            account: KeychainConfig.userAccount
        )
        print(success ? "Пользователь сохранён в Keychain" : "Ошибка сохранения пользователя")
    }

    // Загрузка
    func loadUser() -> UserWithProfile? {
        return KeychainHelper.shared.read(
            service: KeychainConfig.service,
            account: KeychainConfig.userAccount,
            type: UserWithProfile.self
        )
    }
    
    // Миграции
    func migrateFromUserDefaultsToKeychain() {
        print("Начало миграции данных из UserDefaults в Keychain")
        
        // Миграция токена
        if let oldToken = UserDefaults.standard.string(forKey: "authToken") {
            print("Найден старый токен в UserDefaults")
            self.storeToken(oldToken)
            UserDefaults.standard.removeObject(forKey: "authToken")
            print("Токен мигрирован в Keychain")
        } else {
            print("Токен не найден в UserDefaults")
        }
        
        // Миграция пользователя
        if let oldUserData = UserDefaults.standard.data(forKey: "currentUser") {
            print("Найден пользователь в UserDefaults")
            if let oldUser = try? JSONDecoder().decode(UserWithProfile.self, from: oldUserData) {
                self.storeUser(oldUser)
                UserDefaults.standard.removeObject(forKey: "currentUser")
                print("Пользователь мигрирован в Keychain")
            } else {
                print("Ошибка декодирования пользователя")
            }
        } else {
            print("Пользователь не найден в UserDefaults")
        }
    }
}




