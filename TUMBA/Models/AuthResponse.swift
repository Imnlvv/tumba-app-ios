import Foundation

struct AuthResponse: Decodable {
    let messages: String
    let is_success: Bool
    let jwt: String
    var user: UserWithProfile

    enum CodingKeys: String, CodingKey {
        case messages, is_success, jwt, user, profile
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        messages = try container.decode(String.self, forKey: .messages)
        is_success = try container.decode(Bool.self, forKey: .is_success)
        jwt = try container.decode(String.self, forKey: .jwt)
        user = try container.decode(UserWithProfile.self, forKey: .user)
        if let profileData = try? container.decode(Profile.self, forKey: .profile) {
            user.profile = profileData
        }
    }
}
