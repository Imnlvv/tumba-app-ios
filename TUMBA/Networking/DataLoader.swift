
import Foundation
import UIKit

class DataLoader {
    static let shared = DataLoader()
    private let baseURL = "http://localhost:3000"
    private init() {}
    
    // MARK: - Логирование запросов
    private func logRequest(_ request: URLRequest, body: Data?) {
        print("\(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        
        // Логируем заголовки
        if let headers = request.allHTTPHeaderFields {
            print("Headers:")
            headers.forEach { print("   \($0.key): \($0.value)") }
        }
    }
    
    // MARK: - Логирование ответов
    private func logResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        if let error = error {
            print("Ошибка: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Нет HTTP-ответа")
            return
        }
        
//        print("Status Code: \(httpResponse.statusCode)")
        
        if let data = data {
            if String(data: data, encoding: .utf8) != nil {
//                print("Raw response: \(jsonString)")
            } else {
                print("Данные ответа не являются строкой UTF-8")
            }
        }
    }

    // MARK: - Стандартный JSON-запрос
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:],
        completion: @escaping (Result<T, Error>) -> Void
    ) {

        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Логируем ответ
            self.logResponse(data, response, error)

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, !data.isEmpty else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Multipart-запрос (для загрузки файлов)
    func multipartRequest<T: Decodable>(
        endpoint: String,
        method: String = "POST",
        parameters: [String: String] = [:],
        image: UIImage?,
        imageKey: String,
        headers: [String: String] = [:],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        var body = Data()

        // Добавляем текстовые поля
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Добавляем изображение (если есть)
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.7) {
            let filename = "\(UUID().uuidString).jpg"
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                return
            }

            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Перегрузка для Void-ответов (например, для logout)
    func request(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            }
        }.resume()
    }
    
    

    func uploadRequest<T: Decodable>(
        endpoint: String,
        method: String,
        body: Data,
        headers: [String: String],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let fullURL = baseURL + endpoint
        
        guard let url = URL(string: fullURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1,
                                     userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(fullURL)"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Network", code: -1,
                                          userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                var errorMessage = "Server error: \(httpResponse.statusCode)"
                if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                    errorMessage += "\nResponse: \(jsonString)"
                }
                completion(.failure(NSError(domain: "Network", code: httpResponse.statusCode,
                                          userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Network", code: -1,
                                          userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded = try decoder.decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("Ошибка декодирования: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Оригинальный ответ: \(jsonString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}
