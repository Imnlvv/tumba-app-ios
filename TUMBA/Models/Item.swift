import Foundation

struct Item: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let imageUrl: String?
    let purchaseUrl: String?
    let price: String?
    let marketIconUrl: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl = "image_url"
        case purchaseUrl = "purchase_url"
        case price
        case marketIconUrl = "market_icon_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
