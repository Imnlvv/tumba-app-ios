import Foundation

struct Like: Codable, Identifiable {
    let id: Int
    let likeableType: String
    let likeableId: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case likeableType = "likeable_type"
        case likeableId = "likeable_id"
        case createdAt = "created_at"
    }
}
