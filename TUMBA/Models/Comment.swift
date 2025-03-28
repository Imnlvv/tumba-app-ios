import Foundation

struct Comment: Codable, Identifiable {
    let id: Int
    let body: String
    let commenter: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case body
        case commenter
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
