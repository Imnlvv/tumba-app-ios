import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack {
            Spacer()
            Group {
                if viewModel.selectedTab == 0 {
                    HomeView()
                } else if viewModel.selectedTab == 1 {
                    ProfileView()
                } else if viewModel.selectedTab == 2 {
                    AddPostView(profileId: viewModel.currentUserProfile?.id ?? 0)
                } else if viewModel.selectedTab == 3 {
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            MenuBarView(selectedTab: $viewModel.selectedTab)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
