import SwiftUI

struct AddPostView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Добавьте новый пост")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()

                Text("Здесь будет форма для создания нового поста.")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .navigationTitle("Добавить пост")
        }
    }
}
