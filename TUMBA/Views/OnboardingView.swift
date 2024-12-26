import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    number: 1,
                    image: "onboarding1",
                    title: "Добро пожаловать!",
                    description: "Откройте для себя новые возможности."
                )
                .tag(0)

                OnboardingPageView(
                    number: 2,
                    image: "onboarding2",
                    title: "Делитесь идеями",
                    description: "Создавайте, находите вдохновение и делитесь."
                )
                .tag(1)

                OnboardingPageView(
                    number: 3,
                    image: "onboarding3",
                    title: "Готовы начать?",
                    description: "Всё, что нужно, уже под рукой."
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))

            // Кнопки "Далее/Начать" и "Пропустить"
            VStack(spacing: 10) {
                // Кнопка "Далее/Начать"
                Button(action: {
                    if currentPage == 2 {
                        hasSeenOnboarding = true
                    } else {
                        currentPage += 1
                    }
                }) {
                    Text(currentPage == 2 ? "Начать" : "Далее")
                        .fontWeight(.bold)
                        .padding(.vertical, 16) // Увеличенный вертикальный паддинг
                        .padding(.horizontal) // Горизонтальные отступы
                        .frame(maxWidth: .infinity)
                        .background(Color.ocean)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }

                // Кнопка "Пропустить"
                Button(action: {
                    hasSeenOnboarding = true
                }) {
                    Text("Пропустить")
                        .padding(.vertical, 12) // Увеличенный вертикальный паддинг
                        .padding(.horizontal) // Горизонтальные отступы
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            
        }
    }
}
