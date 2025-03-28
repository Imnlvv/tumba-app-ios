import Foundation

struct Profile: Codable, Identifiable {
    let id: Int
    var username: String
    var name: String
    var bio: String?
    var avatarUrl: String?
    let createdAt: String?
    let updatedAt: String?
    var posts: [Post]?
    let items: [Item]?
    let comments: [Comment]?
    let likes: [Like]?
    
    var fullAvatarUrl: String {
        if let avatarUrl = avatarUrl, !avatarUrl.isEmpty {
            let timestamp = Date().timeIntervalSince1970
            return avatarUrl.hasPrefix("http") ? "\(avatarUrl)?t=\(timestamp)" : "http://localhost:3000\(avatarUrl)?t=\(timestamp)"
        }
        return "https://example.com/default-avatar.png?t=\(Date().timeIntervalSince1970)"
    }

    enum CodingKeys: String, CodingKey {
        case id, username, name, bio
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case avatarUrl = "avatar_url"
        case posts, items, comments, likes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        name = try container.decode(String.self, forKey: .name)
        bio = try? container.decode(String.self, forKey: .bio)
        
        // Безопасное декодирование дат (если нет в JSON, будет nil)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)

        
        // Декодируем массивы (если нет в JSON, будет пустой массив)
        posts = (try? container.decodeIfPresent([Post].self, forKey: .posts)) ?? []
        items = (try? container.decode([Item].self, forKey: .items)) ?? []
        comments = (try? container.decode([Comment].self, forKey: .comments)) ?? []
        likes = (try? container.decode([Like].self, forKey: .likes)) ?? []

        // Декодируем avatar_url (строка или объект)
        if let avatarObject = try? container.decode([String: String].self, forKey: .avatarUrl) {
            avatarUrl = avatarObject["url"]
        } else {
            avatarUrl = try? container.decode(String.self, forKey: .avatarUrl)
        }
    }
}

struct ProfileResponse: Codable {
    let profile: Profile
}
