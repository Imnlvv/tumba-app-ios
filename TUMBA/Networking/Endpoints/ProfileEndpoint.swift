enum ProfileEndpoint: Endpoint {
    case userProfile(id: Int)
    
    var compositePath: String {
        switch self {
        case .userProfile(let id): return "/users/\(id)"
        }
    }
    
    var headers: [String: String] {
        ["Accept": "application/json"]
    }
}
