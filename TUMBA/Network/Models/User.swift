import Foundation
struct UserResponse: Codable {
    let user: User
}
struct User: Codable {
    let id: Int
    let email: String
    let admin: Bool
    let createdAt: String
    let updatedAt: String
    let profile: Profile

    enum CodingKeys: String, CodingKey {
        case id, email, admin
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case profile
    }
}
