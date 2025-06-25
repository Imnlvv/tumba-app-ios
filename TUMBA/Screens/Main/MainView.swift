import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Group {
                switch viewModel.selectedTab {
                case 0:
                    HomeView()
                case 1:
                    SettingsView()
                case 2:
                    AddPostView(profileId: viewModel.currentUserProfile?.id ?? 0)
                case 3:
                    FavoritesView()
                case 4:
                    ProfileView()
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            MenuBarView(selectedTab: $viewModel.selectedTab)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
