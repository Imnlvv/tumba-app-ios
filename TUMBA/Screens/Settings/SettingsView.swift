import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false // Хранит состояние темы
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true
    @Environment(\.dismiss) var dismiss // Позволяет закрыть экран
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                    }
                    .onChange(of: isDarkMode) { oldValue, newValue in
                        updateAppearance(newValue)
                    }
                    
                    Section(header: Text("About")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                        }
                        HStack {
                            Text("Developer")
                            Spacer()
                            Text("ADC Hub")
                        }
                    }
                }
                .navigationBarTitle("Settings", displayMode: .inline)
            }
        }
    }
    
    func updateAppearance(_ isDarkMode: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }

    
}
