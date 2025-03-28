import SwiftUI

struct PostView: View, Equatable {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Изображение поста
            AsyncImage(url: URL(string: post.imageUrl?.fullUrl ?? "")) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            } placeholder: {
                Color.gray.opacity(0.3)
                    .frame(height: 200)
            }
        }
        .background(Color.white)
    }
    
    // Реализация Equatable
    static func == (lhs: PostView, rhs: PostView) -> Bool {
        return lhs.post.id == rhs.post.id
    }
}
