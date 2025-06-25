import SwiftUI

struct MenuBarView: View {
    @Binding var selectedTab: Int // Для отслеживания выбранной вкладки

    var body: some View {
        HStack(spacing: 0) {
            MenuButton(icon: "collections_icon", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            MenuButton(icon: "settings_icon_0", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            MenuButton(icon: "plus_icon", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            MenuButton(icon: "favorites_icon", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
            MenuButton(icon: "user_icon", isSelected: selectedTab == 4) {
                selectedTab = 4
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 37)
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MenuButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(icon)
                    .renderingMode(.template)
                    .foregroundColor(isSelected ? .carrot : .gray)
                    .padding(.top, 7)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: 27)
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.white)
        
    }
}
