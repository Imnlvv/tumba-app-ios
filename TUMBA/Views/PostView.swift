import SwiftUI

struct PostView: View {
    let post: Post

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Фон - изображение поста
            AsyncImage(url: URL(string: post.imageUrl?.fullUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3) // Заменяем на серый фон, пока загружается
            }
            .frame(width: 353, height: 550) // Высота блока
            .clipped()

            // Информация о профиле сверху слева
            HStack(alignment: .center, spacing: 10) {
                // Аватар пользователя
                AsyncImage(url: URL(string: post.profile.fullAvatarUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipped()
                } placeholder: {
                        Color.gray.opacity(0.3)
                        .frame(width: 44, height: 44)
                }

                // Имя и никнейм
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.profile.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(post.profile.username)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .padding(3) // Отступы внутри блока
            .padding(.trailing, 20)
            .background(Color.carrot) // Фон блока
        
        }
        .frame(height: 550) // Высота блока
        .padding(.horizontal)
    }
}
