import Foundation

struct Tag: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let taggingsCount: Int
    let tagCategoryName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case taggingsCount = "taggings_count"
        case tagCategoryName = "tag_category_name"
    }
}
