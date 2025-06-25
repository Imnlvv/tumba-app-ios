import SwiftUI

struct CommentView: View {
    let comment: Comment
    let profile: Profile?
    var onDelete: (() -> Void)?
    @State private var showDeleteAlert = false
    
    // Добавляем проверку, принадлежит ли комментарий текущему пользователю
    private var isCurrentUserComment: Bool {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            return false
        }
        return comment.profileId == currentUserId
    }
    
    private var isTemporaryComment: Bool {
        comment.id >= 100_000 && comment.id <= 999_999 // Наш диапазон для временных ID
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                if let avatarUrl = profile?.fullAvatarUrl {
                    // Ава комментатора
                    AsyncImage(url: URL(string: avatarUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        case .failure:
                            // Дефолтный аватар
                            placeholderAvatar
                        case .empty:
                            ProgressView()
                                .frame(width: 32, height: 32)
                        @unknown default:
                            // Дефолтный аватар
                            placeholderAvatar
                        }
                    }
                } else {
                    // Дефолтный аватар
                    placeholderAvatar
                }
                
                // Текст комментария
                Text(formatUsername(profile?.username ?? "Загрузка..."))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.Custom.gray)
                
                Spacer()
                
                // Кнопка удаления для своих комментариев
                if isCurrentUserComment {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image("bin_icon")
                            .renderingMode(.template)
                            .foregroundColor(Color.Custom.gray)
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Удалить комментарий?"),
                            message: Text("Вы уверены, что хотите удалить этот комментарий?"),
                            primaryButton: .destructive(Text("Удалить"), action: onDelete),
                            secondaryButton: .cancel()
                        )
                    }
                }

            }
                
            VStack(alignment: .leading, spacing: 10) {
                // Текст комментария
                Text(comment.body)
                    .font(.system(size: 16))
                    .foregroundColor(Color.Custom.gray)
                
                // Дата создания
                Text(formattedDate(from: comment.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

        }
        .padding()
        .background(Color.Custom.lightGray.opacity(0.3))
        .cornerRadius(10)
        .opacity(isTemporaryComment ? 0.7 : 1.0) // Полупрозрачность для временных
    }
    
    // MARK: - func()
    
    // Аватар пользователя
    private var placeholderAvatar: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
            )
    }
    
    // Никнейм пользователя
    private func formatUsername(_ username: String) -> String {
        if username.hasPrefix("@") {
            return username
        } else {
            return "@" + username
        }
    }
    
    // Форматор даты типа "2025-03-11T18:04:18+03:00"
    private func formattedDate(from isoDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd.MM.yyyy   HH:mm"
        outputFormatter.locale = Locale(identifier: "ru_RU")

        if let date = inputFormatter.date(from: isoDate) {
            return outputFormatter.string(from: date)
        } else {
            return "Неизвестная дата"
        }
    }
}
