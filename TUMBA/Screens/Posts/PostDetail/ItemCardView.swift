import SwiftUI

struct ItemCardView: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            itemImageSection
            itemNameSection
            itemPriceAndMarketSection
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
        }
    }
    
    private var itemPriceAndMarketSection: some View {
        HStack() {
            marketIconSection
            Spacer()
            priceSection
        }
    }

    // Цена
    private var priceSection: some View {
        Group {
            if let price = Double(item.price ?? "") {
                Text("\(Int(price)) ₽")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
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



struct ItemPreviewView: View {
    let item: Item
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Изображение товара
            AsyncImage(url: URL(string: item.imageUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 82, height: 82)
                        .clipped()
                case .failure, .empty:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
            .padding(.trailing, 15)
                        
            // Информация о товаре
            VStack(alignment: .leading, spacing: 9) {
                // Название товара
                Text(item.name)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Ссылка на товар (обрезанная)
                if let purchaseUrl = item.purchaseUrl {
                    Text(truncateString(purchaseUrl, to: 27))
                        .font(.system(size: 13))
                        .foregroundColor(Color.Custom.gray.opacity(0.7))
                        .lineLimit(1)
                }
                
                // Цена
                if let price = item.price {
                    Text(price)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.top, 4)
                }
            }
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
                        
            // Кнопка удаления
            Button(action: onDelete) {
                Image("bin_icon") // Убедитесь, что у вас есть этот ассет
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
        .padding(.bottom, 12)
    }
    
    private var placeholderImage: some View {
        Color.gray.opacity(0.1)
            .frame(width: 82, height: 82)
            .cornerRadius(8)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.gray.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            ))
    }
    
    func truncateString(_ string: String, to length: Int) -> String {
        if string.count > length {
            let endIndex = string.index(string.startIndex, offsetBy: length)
            return String(string[..<endIndex]) + "…"  // Добавляем многоточие
        } else {
            return string
        }
    }
}
