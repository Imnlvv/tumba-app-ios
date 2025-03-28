import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let admin: Bool?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, email, admin
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

