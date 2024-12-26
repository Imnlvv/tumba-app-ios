import SwiftUI

// Модель моковых данных для профиля
struct MockProfile: Identifiable {
    var id = UUID()
    var avatarUrl: String
    var name: String
    var username: String
}

// Моковые данные
let mockProfile = MockProfile(
    avatarUrl: "https://i.pinimg.com/736x/04/ea/d2/04ead251bf8d242d490c3ea8912a52e0.jpg",
    name: "Marg.o",
    username: "@margo_sha"
)

// Вью для профиля
struct ProfileView: View {
    @State private var showEditProfile = false
    var body: some View {
        VStack(spacing: 16) {
            // Аватар пользователя
            AsyncImage(url: URL(string: mockProfile.avatarUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 220)
                    .clipShape(Rectangle())
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 220, height: 220)
            }

            // Имя пользователя
            Text(mockProfile.name)
                .foregroundColor(.ocean)
                .font(.title)
                .fontWeight(.bold)

            // Никнейм пользователя
            Text(mockProfile.username)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 7)
                .background(Color.carrot)

            // Кнопка "Редактировать профиль"
            // Кнопка "Редактировать профиль"
            Button(action: {
                showEditProfile = true // Устанавливаем состояние для перехода
            }) {
                Text("Редактировать профиль")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.ocean)
            }
            .padding(.horizontal)
            .sheet(isPresented: $showEditProfile) {
                NavigationView {
                    EditProfileView() // Экран для редактирования
                }
            }

            Spacer()
        }
        .padding()
    }
}

// Превью для SwiftUI
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
