enum TagEndpoint: Endpoint {
    case tags
    
    var compositePath: String {
        switch self {
        case .tags: return "/tags"
        }
    }
    var headers: [String: String] {
        [:]
    }
    var parameters: [String: String]? {
        nil
    }
}
