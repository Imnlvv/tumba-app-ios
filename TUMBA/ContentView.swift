import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @StateObject private var mainViewModel = MainViewModel()
    
    var body: some View {
        
        if !hasSeenOnboarding {
            OnboardingView()
        } else if !isLoggedIn {
            LoginView()
        } else {
            MainView(viewModel: mainViewModel)
        }
    }
}
