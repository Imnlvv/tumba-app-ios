import Foundation
import SwiftUI

struct Request {
    enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    enum Body {
        case data(Data?)
        case multipart(parameters: [String: String], image: UIImage?, imageKey: String)
    }

    var endpoint: Endpoint
    var method: RequestMethod
    var parameters: [String: String]?
    var body: Body?
    var timeoutInterval: TimeInterval

    init(
        endpoint: Endpoint,
        method: RequestMethod = .get,
        parameters: [String: String]? = nil,
        body: Body? = nil,
        timeoutInterval: TimeInterval = 60
    ) {
        self.endpoint = endpoint
        self.method = method
        self.parameters = parameters
        self.body = body
        self.timeoutInterval = timeoutInterval

        if var endpointParameters = endpoint.parameters {
            for (key, value) in parameters ?? [:] {
                endpointParameters[key] = value
            }
            self.parameters = endpointParameters
        }
    }
}
