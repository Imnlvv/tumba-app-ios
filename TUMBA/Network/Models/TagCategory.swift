import Foundation

struct TagCategory: Identifiable, Codable, Hashable, Equatable {
    let id: Int
    let name: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct TagCategoriesResponse: Codable {
    let tagCategories: [TagCategory]

    enum CodingKeys: String, CodingKey {
        case tagCategories = "tag_categories"
    }
}
