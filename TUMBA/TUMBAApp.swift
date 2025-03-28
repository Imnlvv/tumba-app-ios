import SwiftUI

@main
struct TUMBAApp: App {
    
    init() {
        // Вызываем миграцию при старте приложения
        AuthService.shared.migrateFromUserDefaultsToKeychain()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

