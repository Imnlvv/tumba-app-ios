import SwiftUI

struct MenuBarView: View {
    @Binding var selectedTab: Int // Для отслеживания выбранной вкладки

    var body: some View {
        HStack(spacing: 0) { // Убираем отступы между кнопками
            MenuButton(icon: "house", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            MenuButton(icon: "person", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            MenuButton(icon: "plus.circle", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            MenuButton(icon: "gearshape", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 47) // Меню растягивается по ширине и высоте
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom) // Игнорируем безопасную зону внизу
    }
}

struct MenuButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .carrot : Color.gray)
                    .padding(.top, 12)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Заполнение доступного пространства
        }
        .frame(maxWidth: .infinity, maxHeight: 47) // Устанавливаем равную высоту для всех кнопок
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.white)// Игнорируем безопасную зону внизу
        
    }
}
