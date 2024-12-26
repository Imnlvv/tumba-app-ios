import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0 // Индекс текущей вкладки
    @State private var currentUserProfile: Profile?

    var body: some View {
        VStack {
            Spacer()

            // Основной контент в зависимости от выбранной вкладки
            Group {
                if selectedTab == 0 {
                    HomeView()
                } else if selectedTab == 1 {
                    ProfileView()
                } else if selectedTab == 2 {
                    AddPostView()
                } else if selectedTab == 3 {
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            

            // Меню
            MenuBarView(selectedTab: $selectedTab)
        }
    }
}
