import SwiftUI

struct PostDetailView: View {
    let post: Post
    
    // Вспомогательные переменные для загрузки изображений
    private var postImageUrl: URL? {
        URL(string: post.imageUrl?.fullUrl ?? "")
    }
    
    private var profileAvatarUrl: URL? {
        URL(string: post.profile?.fullAvatarUrl  ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack {
                postImageSection
                postContentSection
                itemsSection
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle(post.profile?.username  ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - func()

    // Раздел с изображением поста
    private var postImageSection: some View {
        AsyncImage(url: postImageUrl) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: 353, height: 550)
                .clipped()
        } placeholder: {
            Color.gray.opacity(0.3)
                .frame(width: 353, height: 550)
        }
    }
    
    // Основной контент поста
    private var postContentSection: some View {
        VStack(alignment: .leading, spacing: 30) {
            createdAtTextSection
            postTextSection
            tagsSection
            userInfoSection
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 30, trailing: 20))
        .background(Color.gray.opacity(0.04))
        .frame(maxWidth: 353, maxHeight: .infinity)
    }

    // Блок информации о пользователе
    private var userInfoSection: some View {
        HStack(spacing: 10) {
            AsyncImage(url: profileAvatarUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } placeholder: {
                Color.gray.opacity(0.3)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            }
            
            Text("\(post.profile?.username ?? "username")")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.Custom.gray)
        }
        .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
        .background(Color.white)
        .clipShape(Capsule())
    }
    
    // Блок тегов (если есть)
    private var tagsSection: some View {
        Group {
            if !post.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.tags, id: \.self) { tag in
                            Text(tag.capitalized.uppercased())
                                .padding(.horizontal, 12)
                                .font(.system(size: 14))
                                .frame(height: 30)
                                .foregroundColor(.white)
                        }
                        .background(Color.Custom.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
    
    // Текстовая часть поста
    private var createdAtTextSection: some View {
        Text(formattedDate(from: post.createdAt))
            .font(.system(size: 13))
            .fontWeight(.regular)
            .foregroundColor(Color.Custom.gray.opacity(0.5))
    }
    
    private func formattedDate(from isoDate: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        let outputFormatter = DateFormatter()
        
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        outputFormatter.dateFormat = "d MMMM, yyyy"
        outputFormatter.locale = Locale(identifier: "ru_RU")
        
        if let date = dateFormatter.date(from: isoDate) {
            return outputFormatter.string(from: date)
        } else {
            return "Неизвестная дата"
        }
    }
    
    private var postTextSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.title.uppercased())
                .font(.system(size: 23))
                .fontWeight(.semibold)
                .foregroundColor(Color.Custom.gray)
            
            Text(post.description)
                .font(.body)
                .fontWeight(.regular)
        }
    }
    
    // Секция товаров
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Товары".uppercased())
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 23))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray)
                .padding(EdgeInsets(top: 40, leading: 26, bottom: 0, trailing: 0))
            
            if let items = post.items, !items.isEmpty {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(items) { item in
                        ItemCardView(item: item)
                            .frame(minHeight: 250)
                            .alignmentGuide(.top) { _ in 0 }
                    }
                }
                .padding(.horizontal, 26)
            } else {
                Text("Автор не добавил товаров")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(EdgeInsets(top: 0, leading: 26, bottom: 40, trailing: 0))
            }
        }
    }
}
