import Foundation

struct Comment: Codable, Identifiable {
    let id: Int
    let body: String
    let createdAt: String
    let updatedAt: String?
    let postId: Int
    let profileId: Int
    
    enum CodingKeys: String, CodingKey {
        case id, body
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case postId = "post_id"
        case profileId = "profile_id"
    }
}

struct CommentResponse: Codable {
    let comments: [Comment]
}

struct SingleCommentResponse: Codable {
    let comment: Comment
}
