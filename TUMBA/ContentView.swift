import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        if !hasSeenOnboarding {
            // Онбординг
            OnboardingView()
        } else if !isLoggedIn {
            // Экран логина
            LoginView()
        } else {
            // Основной экран
            MainView()
        }
    }
}

#Preview {
    MainView()
}
