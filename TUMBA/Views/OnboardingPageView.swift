import SwiftUI

struct OnboardingPageView: View {
    let number: Int // Номер пункта
    let image: String
    let title: String
    let description: String

    var body: some View {
        VStack {
            // Номер в синем квадрате
            ZStack {
                Rectangle()
                    .fill(Color.ocean)
                    .frame(width: 53, height: 53)
                Text("\(number)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top)
            Spacer()
            // Средняя часть — картинка
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300)
            Spacer()
            // Нижняя часть — текстовая информация
            VStack(spacing: 35) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 0)
            .padding(.bottom)
        }
        .frame(maxHeight: .infinity) // Заполнение пространства
        .padding(.vertical, 20) // Отступы сверху и снизу
    }
}
