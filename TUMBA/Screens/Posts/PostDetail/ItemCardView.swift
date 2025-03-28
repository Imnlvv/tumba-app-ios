import SwiftUI

struct ItemCardView: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            itemImageSection
            itemNameSection
        }
        .frame(width: 170, height: 200)
    }
    
    // MARK: - func()

    // Изображение товара
    private var itemImageSection: some View {
        ZStack(alignment: .topLeading) {
            if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 170, height: 180)
                .clipped()
            }

            // Цена и иконка магазина
            HStack(alignment: .top) {
                priceSection
                Spacer()
                marketIconSection
            }
        }
    }

    // Цена
    private var priceSection: some View {
        Group {
            if let price = Double(item.price ?? "") {
                Text("\(Int(price)) ₽")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .background(Color.carrot)
            } else {
                Text("Цена не указана")
                    .padding(8)
                    .background(Color.gray.opacity(0.3))
            }
        }
    }

    // Иконка магазина
    private var marketIconSection: some View {
        Group {
            if let marketIconUrl = item.marketIconUrl, let url = URL(string: marketIconUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 6))
            } else {
                Spacer().frame(width: 24, height: 24) // Резервируем место под иконку
            }
        }
    }

    // Название товара
    private var itemNameSection: some View {
        Text(item.name)
            .font(.footnote)
            .fontWeight(.regular)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2) // Ограничиваем в 2 строки
            .fixedSize(horizontal: false, vertical: true)
            .frame(height: 40, alignment: .top)
    }
}
