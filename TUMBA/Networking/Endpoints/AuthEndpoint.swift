enum AuthEndpoint: Endpoint {
    case signIn
    case signUp
    case signOut
    case deleteAccount
    case meProfile
    case profile(id: Int)
    case csrfToken
    case uploadAvatar(profileId: Int)
    
    var compositePath: String {
        switch self {
        case .signIn: return "/sign_in"
        case .signUp: return "/sign_up"
        case .signOut: return "/sign_out"
        case .deleteAccount: return "/delete_account"
        case .meProfile: return "/me/profile"
        case .profile(let id): return "/profiles/\(id)"
        case .csrfToken: return "/"
        case .uploadAvatar(let profileId): return "/profiles/\(profileId)"
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .signIn, .signUp:
            return [
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
        case .profile, .meProfile:
            guard let token = AuthService.shared.loadToken() else {
                return ["Content-Type": "application/json"]
            }
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)"
            ]
        case .uploadAvatar:
            guard let token = AuthService.shared.loadToken() else {
                return [:]
            }
            return [
                "Authorization": "Bearer \(token)"
            ]
        default:
            return ["Accept": "application/json"]
        }
    }
}
