import SwiftUI

struct EditProfileView: View {
    @State private var name: String = "Marg.o" // Изначальное имя
    @State private var username: String = "@margo_sha" // Изначальный никнейм

    var body: some View {
        Form {
            Section(header: Text("Аватар")) {
                Text("Функция изменения аватара в разработке.")
            }

            Section(header: Text("Имя")) {
                TextField("Введите имя", text: $name)
            }

            Section(header: Text("Никнейм")) {
                TextField("Введите никнейм", text: $username)
            }

            Button(action: {
                print("Сохраняем изменения: Имя - \(name), Никнейм - \(username)")
            }) {
                Text("Сохранить изменения")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.ocean)
                    .foregroundColor(.white)
            }
        }
        .navigationTitle("Редактировать профиль")
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
