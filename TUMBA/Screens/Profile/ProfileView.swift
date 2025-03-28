//  ProfileView.swift
//  Для страницы профиля есть еще идея реализовать вид чужого/текущего профиля: хочу использовать один визуальный образ (как сейчас), но интегрировать параметр isCurrentUser (чтобы определить, отображается профиль текущего пользователя или чужого, и тем самым контролировать показываемый контент: скрывать или показывать определённые элементы (кнопки "Редактировать профиль", "Удалить профиль", "Выход" и тд))

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showDeleteConfirmation = false
    @State private var isAccountDeleted = false
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if let profile = viewModel.profile {
                        profileHeaderSection(profile: profile)
                        postsSection(profile: profile)
                        Spacer()
                        HStack {
                            deleteButton
                            logoutButton
                        }
                    } else if viewModel.isLoading {
                        loadingSection
                    } else if let errorMessage = viewModel.errorMessage {
                        errorSection(errorMessage: errorMessage)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel.profile == nil {
                    viewModel.loadProfile()
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Удалить профиль?"),
                    message: Text("Вы уверены, что хотите удалить профиль? Это действие нельзя отменить."),
                    primaryButton: .destructive(Text("Удалить"), action: deleteAccount),
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingEditProfile) {
                if let profile = viewModel.profile {
                    EditProfileView(
                        name: profile.name,
                        username: profile.username,
                        onSave: { newName, newUsername, newImage in
                            // Обновляем данные в viewModel
                            viewModel.updateProfile(
                                name: newName,
                                username: newUsername,
                                image: newImage
                            )
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - func()
    
    // Верхняя секция профиля (фото, имя, никнейм, "редактировать профиль", кол-во постов)
    private func profileHeaderSection(profile: Profile) -> some View {
        VStack(spacing: 30) {
            // Аватар профиля
            VStack(spacing: 15) {
                AsyncImage(url: URL(string: profile.fullAvatarUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    } else if phase.error != nil {
                        // Показываем placeholder при ошибке
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 150, height: 150)
                    } else {
                        // Показываем индикатор загрузки
                        ProgressView()
                    }
                }
                
                VStack(spacing: 2) {
                    // Имя пользователя
                    Text(profile.name.uppercased())
                        .font(.system(size: 26))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.Custom.gray)
                    
                    // Никнейм
                    Text("@\(profile.username)")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.Custom.gray.opacity(0.5))
                }
            }
            
            // Кнопка редактирования профиля
            Button(action: {
                showingEditProfile = true
            }) {
                HStack(alignment: .center, spacing: 10) {
                    Text("Редактировать профиль")
                        .font(.system(size: 16))
                        .fontWeight(.regular)
                        .foregroundColor(Color.Custom.gray)
                    Image("Edit")
                        .frame(width: 30, height: 30)
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
                .background(Color.Custom.lightGray)
                .cornerRadius(40)
            }
            
            // Статистика: количество постов
            HStack(spacing: 20) {
                VStack {
                    Text("\(profile.posts?.count ?? 0)")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.Custom.gray)
                    Text("постов")
                        .font(.system(size: 16))
                        .fontWeight(.regular)
                        .foregroundColor(Color.Custom.gray.opacity(0.5))
                }
            }
        }
    }
    
    // Публикации
    private func postsSection(profile: Profile) -> some View {
        VStack {
            // Заголовок "Публикации"
            Text("Публикации".uppercased())
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 23))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray)
                .padding(EdgeInsets(top: 40, leading: 16, bottom: 26, trailing: 0))
            
            // Список публикаций (если есть)
            if let posts = profile.posts, !posts.isEmpty {
                VStack(spacing: 16) {
                    ForEach(posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostView(post: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Нет постов")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 40, trailing: 0))
            }
        }
    }
    
    // Удаление профиля
    private var deleteButton: some View {
        Button(action: {
            showDeleteConfirmation = true
        }) {
            VStack {
                Text("Удалить профиль")
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                    .foregroundColor(Color.Custom.gray)
            }
            .padding(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 25))
            .background(Color.Custom.lightGray)
            .cornerRadius(40)
        }
    }
    
    private func deleteAccount() {
        viewModel.deleteAccount { success in
            if success {
                isAccountDeleted = true
                // Перенаправление на экран входа
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        window.rootViewController = UIHostingController(rootView: LoginView())
                        window.makeKeyAndVisible()
                    }
                }
            }
        }
    }
    
    // Кнопка выхода
    private var logoutButton: some View {
        Button(action: viewModel.logout) {
            HStack(alignment: .center, spacing: 10) {
                Text("Выйти")
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                    .foregroundColor(Color.Custom.gray)
                Image(systemName: "arrow.right.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.Custom.gray.opacity(0.5))
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
            .background(Color.Custom.lightGray)
            .cornerRadius(40)
        }
        .padding(.vertical, 30)
    }
    
    // Загрузка данных профиля
    private var loadingSection: some View {
        Text("Загрузка профиля...")
            .font(.title2)
            .foregroundColor(.gray)
    }
    
    // Ошибка профиля
    private func errorSection(errorMessage: String) -> some View {
        Text(errorMessage)
            .font(.title2)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    // Вспомогательные функции
    private func getUrl(from src: String?) -> URL? {
        if let src = src {
            return URL(string: "http://localhost:3000" + src)
        }
        return nil
    }
}
