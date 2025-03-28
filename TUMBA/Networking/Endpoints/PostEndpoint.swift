enum PostEndpoint: Endpoint {
    case posts
    case uploads
    case currentUser
    
    var compositePath: String {
        switch self {
        case .posts: return "/posts"
        case .uploads: return "/uploads"
        case .currentUser: return "/users/me"
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .uploads:
            return [:]
        default:
            return ["Content-Type": "application/json"]
        }
    }
}
