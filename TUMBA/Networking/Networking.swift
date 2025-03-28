import Foundation
import SwiftUI

protocol NetworkingLogic {
    typealias Response = ((_ response: Result<Networking.ServerResponse, Error>) -> Void)
    func executeRequest(with request: Request, completion: @escaping Response)
}

// MARK: - Модели данных и ошибки сети
enum Networking {
    struct ServerResponse {
        var data: Data?
        var response: URLResponse?
    }

    enum Error: Swift.Error {
        case emptyData
        case invalidRequest
        case invalidURL
        case decodingError(DecodingError)
        case authenticationRequired
        case resourceNotFound
        case serverError(statusCode: Int, message: String, responseData: Data?)
        case invalidResponse(statusCode: Int, data: Data?, message: String)
        case other(Swift.Error)
        
        var localizedDescription: String {
            switch self {
            case .emptyData: return "No data received"
            case .invalidRequest: return "Invalid request"
            case .invalidURL: return "Invalid URL"
            case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
            case .authenticationRequired: return "Authentication required"
            case .resourceNotFound: return "Resource not found"
            case .serverError(let statusCode, let message, _):
                return "Server error \(statusCode): \(message)"
            case .invalidResponse(let statusCode, _, let message):
                return "Invalid response (\(statusCode)): \(message)"
            case .other(let error): return error.localizedDescription
            }
        }
    }
}

// MARK: - Базовый сетевой обработчик
final class BaseURLWorker: NetworkingLogic {
    var baseUrl: String
    private let logger: NetworkLoggerProtocol?

    init(baseUrl: String, logger: NetworkLoggerProtocol? = nil) {
        self.baseUrl = baseUrl
        self.logger = logger
    }

    func executeRequest(with request: Request, completion: @escaping Response) {
        guard let urlRequest = convert(request) else {
            completion(.failure(Networking.Error.invalidRequest))
            return
        }

        logger?.logRequest(urlRequest, body: getBodyData(from: request.body))

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            self.logger?.logResponse(data, response, error)

            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(Networking.ServerResponse(data: data, response: response)))
        }

        task.resume()
    }

    private func convert(_ request: Request) -> URLRequest? {
        guard let url = generateDestinationURL(for: request) else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = request.endpoint.headers
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeoutInterval

        switch request.body {
        case .data(let data):
            urlRequest.httpBody = data
        case .multipart(let parameters, let image, let imageKey):
            urlRequest.httpBody = createMultipartBody(parameters: parameters, image: image, imageKey: imageKey)
        case .none:
            break
        }

        return urlRequest
    }

    private func generateDestinationURL(for request: Request) -> URL? {
        guard
            let url = URL(string: baseUrl),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        components.path += request.endpoint.compositePath
        components.queryItems = request.parameters?.map { URLQueryItem(name: $0, value: $1) }

        return components.url
    }

    private func createMultipartBody(parameters: [String: String], image: UIImage?, imageKey: String) -> Data {
        let boundary = UUID().uuidString
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
        return body
    }

    private func getBodyData(from body: Request.Body?) -> Data? {
        switch body {
        case .data(let data): return data
        case .multipart(let parameters, let image, let imageKey):
            return createMultipartBody(parameters: parameters, image: image, imageKey: imageKey)
        case .none: return nil
        }
    }
}

// MARK: - Протокол и реализация логгера
protocol NetworkLoggerProtocol {
    func logRequest(_ request: URLRequest, body: Data?)
    func logResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?)
}

class NetworkLogger: NetworkLoggerProtocol {
    func logRequest(_ request: URLRequest, body: Data?) {
        print("\(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        
        if let headers = request.allHTTPHeaderFields {
            print("Headers:")
            headers.forEach { print("   \($0.key): \($0.value)") }
        }
        
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }
    
    func logResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("No HTTP Response")
            return
        }
        
        print("Status Code: \(httpResponse.statusCode)")
        
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Response Data: \(dataString)")
        }
    }
}
