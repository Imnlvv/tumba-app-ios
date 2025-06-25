import SwiftUI
import WaterfallGrid

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @State private var showDeleteConfirmation = false
    @State private var isAccountDeleted = false
    @State private var showingEditProfile = false
    @State private var showingFollowAction = false
    @State private var isGridViewActive = false

    
    // Инициализатор для текущего пользователя
    init() {
        _viewModel = StateObject(wrappedValue: ProfileViewModel())
    }
    
    // Инициализатор для чужого профиля
    init(userId: Int) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if let profile = viewModel.profile {
                        let _ = print("Rendering profile: \(profile.username)")
                        
                        //Верхняя секция профиля
                        profileHeaderSection(profile: profile)
                            .padding(.bottom, 20)
                        if !viewModel.isCurrentUser {
                            // Подписки
                            followButton
                        }
                        // Посты
                        postsSection(profile: profile)
                        if viewModel.isCurrentUser {
                            Spacer()
                            // Секция текущего профиля (кнопка удалить и выйти)
                            currentUserActions
                        }
                    } else if viewModel.isLoading {
                        // Прогрузка
                        loadingSection
                    } else if let errorMessage = viewModel.errorMessage {
                        // Ошибка профиля
                        errorSection(errorMessage: errorMessage)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                print("Профиль прогрузился")
                if viewModel.profile == nil {
                    print("Загрузка профиля...")
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

    // Секция текущего профиля (кнопка удалить и выйти)
    private var currentUserActions: some View {
        HStack(spacing: 35) {
            deleteButton
            logoutButton
        }
    }

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
                    Text(formatUsername(profile.username))
                        .font(.system(size: 16))
                        .fontWeight(.regular)
                        .foregroundColor(Color.Custom.gray.opacity(0.5))
                }
            }
            
            // Статистика
            HStack(spacing: 20) {
                VStack {
                    Text("\(profile.subscriptions)")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.Custom.gray)
                    Text("подписки")
                        .font(.system(size: 16))
                        .fontWeight(.regular)
                        .foregroundColor(Color.Custom.gray.opacity(0.5))
                }
                VStack {
                    Text("\(profile.subscribers)")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.Custom.gray)
                    Text("подписчики")
                        .font(.system(size: 16))
                        .fontWeight(.regular)
                        .foregroundColor(Color.Custom.gray.opacity(0.5))
                }
            }
            
            // Кнопка редактирования профиля (только для текущего пользователя)
            if viewModel.isCurrentUser {
                Button(action: {
                    showingEditProfile = true
                }) {
                    HStack(alignment: .center, spacing: 10) {
                        Text("Редактировать профиль")
                            .font(.system(size: 16))
                            .fontWeight(.regular)
                            .foregroundColor(Color.Custom.gray)
                        Image("settings_icon")
                            .frame(width: 30, height: 30)
                    }
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
                    .background(Color.Custom.lightGray)
                    .cornerRadius(40)
                }
            }
        }
    }
    
    // Функция для корректного отображения никнейма
    private func formatUsername(_ username: String) -> String {
        if username.hasPrefix("@") {
            return username
        } else {
            return "@" + username
        }
    }
    
    // Публикации с переключателем вида
    private func postsSection(profile: Profile) -> some View {
        VStack(spacing: 0) {
            // Заголовок по центру
            Text("Публикации".uppercased())
                .frame(maxWidth: .infinity)
                .font(.system(size: 21))
                .fontWeight(.medium)
                .foregroundColor(Color.Custom.gray)
                .padding(.top, 25)
                .padding(.bottom, 16)
            
            // Иконки переключения вида
            HStack {
                // Переключатель вида
                HStack(spacing: 16) {
                    // Кнопка списка
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isGridViewActive = false
                        }
                    }) {
                        Image("list.bullet_icon")
                            .font(.system(size: 20))
                            .foregroundColor(Color.Custom.gray)
                            .opacity(isGridViewActive ? 0.5 : 1.0)
                    }
                    
                    // Кнопка сетки
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isGridViewActive = true
                        }
                    }) {
                        Image("square.grid.2x2_icon")
                            .font(.system(size: 20))
                            .foregroundColor(Color.Custom.gray)
                            .opacity(isGridViewActive ? 1.0 : 0.5)
                    }
                }
                .padding(.leading, 16)
                .padding(.bottom, 30)
                Spacer()
            }
            
            // Контент в зависимости от выбранного вида
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else if let posts = profile.posts {
                if posts.isEmpty {
                    Text("Нет постов")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                } else {
                    Group {
                        if isGridViewActive {
                            // Водопадная сетка
                            ScrollView {
                                WaterfallGrid(posts, id: \.id) { post in
                                    NavigationLink(destination: PostDetailView(post: post)) {
                                        PostView(post: post)
                                            .frame(width: (UIScreen.main.bounds.width - 38) / 2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .gridStyle(
                                    columns: 2,
                                    spacing: 10,
                                    animation: .easeInOut
                                )
                                .padding(.bottom, 15)
                            }
                        } else {
                            // Обычная лента
                            LazyVStack(spacing: 16) {
                                ForEach(posts) { post in
                                    NavigationLink(destination: PostDetailView(post: post)) {
                                        PostView(post: post)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                }
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
            VStack {
                Text("Выйти")
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                    .foregroundColor(Color.Custom.gray)
            }
            .padding(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 25))
            .background(Color.Custom.lightGray)
            .cornerRadius(40)
        }
        .padding(.vertical, 30)
    }

    // Кнопка подписки/отписки
    private var followButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                if viewModel.profile?.isFollowing == true {
                    viewModel.profile?.isFollowing = false
                    viewModel.profile?.subscribers = max(0, (viewModel.profile?.subscribers ?? 1) - 1)
                } else {
                    viewModel.profile?.isFollowing = true
                    viewModel.profile?.subscribers = (viewModel.profile?.subscribers ?? 0) + 1
                }
            }
        }) {
            Text(viewModel.profile?.isFollowing == true ? "Отписаться" : "Подписаться")
                .font(.system(size: 16))
                .fontWeight(.regular)
                .foregroundColor(viewModel.profile?.isFollowing == true ? Color.Custom.gray : .white)
                .padding(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 25))
                .background(viewModel.profile?.isFollowing == true ? Color.Custom.lightGray : Color.Custom.carrot)
                .cornerRadius(40)
                .animation(.easeInOut, value: viewModel.profile?.isFollowing)
        }
        .padding(.bottom, 20)
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
