import Foundation

struct Profile: Codable, Identifiable {
    let id: Int
    let username: String
    let name: String
    let bio: String?
    let avatarUrl: String
    let createdAt: String
    let updatedAt: String
    let posts: [Post]?
    let items: [Item]?
    let comments: [Comment]?
    let likes: [Like]?

    var fullAvatarUrl: String {
        "http://localhost:3000\(avatarUrl)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case bio
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case posts
        case items
        case comments
        case likes
    }
}
struct ProfileResponse: Codable {
    let profile: Profile
}

