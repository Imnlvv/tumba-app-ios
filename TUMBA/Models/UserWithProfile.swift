import Foundation

struct UserWithProfile: Codable {
    let id: Int
    let email: String
    var admin: Bool?
    var createdAt: String?
    var updatedAt: String?
    var profile: Profile?

    enum CodingKeys: String, CodingKey {
        case id, email, admin, profile
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
