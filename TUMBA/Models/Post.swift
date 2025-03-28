import Foundation

struct Post: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let imageUrl: ImageURL?
    let isPublic: Bool
    let createdAt: String
    let updatedAt: String
    let tags: [String]
    var profile: Profile?
    let items: [Item]?
    let comments: [Comment]?
    let likes: [Like]?
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, profile, tags, items, comments, likes
        case imageUrl = "image_url"
        case isPublic = "public"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    struct ImageURL: Codable {
        let url: String?

        var fullUrl: String {
            if let url = url, url.hasPrefix("http") {
                return url
            } else if let url = url {
                return "http://localhost:3000\(url)"
            } else {
                return ""
            }
        }
    }
}

struct PostResponse: Codable {
    let posts: [Post]
    
}

struct ImageUploadResponse: Decodable {
    let url: String
}


