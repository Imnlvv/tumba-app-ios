import Foundation

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    var imageUrl: ImageURL?
    let isPublic: Bool
    var createdAt: String?
    let updatedAt: String?
    let tags: [String]
    var profile: Profile?
    let items: [Item]?
    let comments: [Comment]?
    var likes: [Like]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, tags, items, comments, likes, profile
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

struct PostsResponse: Codable {
    let posts: [Post]
}

struct PostResponse: Codable {
    let post: Post
}

struct ImageUploadResponse: Decodable {
    let url: String
}



