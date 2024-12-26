import Foundation

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let imageUrl: ImageUrl? // URL изображения
    let isPublic: Bool
    let createdAt: String
    let updatedAt: String
    let tags: [String]? // Список тегов
    let profile: Profile // Профиль автора поста
    let items: [Item]? // Связанные товары
    let comments: [Comment]? // Связанные комментарии
    let likes: [Like]? // Лайки (можно оставить пустым для будущего)

    struct ImageUrl: Codable {
            let url: String

            var fullUrl: String {
                "http://localhost:3000\(url)" // Замените на ваш базовый URL
            }
        }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageUrl = "image_url"
        case isPublic = "public"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case tags
        case profile
        case items
        case comments
        case likes
    }
}
struct PostResponse: Codable {
    let posts: [Post]
}
