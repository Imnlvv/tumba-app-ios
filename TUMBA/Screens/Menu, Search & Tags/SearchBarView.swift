import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var placeholder: String = "Поиск"

    var body: some View {
        HStack {
            VStack(spacing: 0) {
                TextField(placeholder, text: $searchText)
                    .padding(.leading, 15)
                    .padding(.top, 15)
                    .frame(height: 64)
                    .background(Color.white)
                Rectangle()
                    .fill(searchText.isEmpty ? Color.gray.opacity(0.3) : Color.ocean)
                    .frame(height: 2)
                    .padding(.trailing, 15)
            }
                    
            Spacer()
            Image(systemName: "magnifyingglass")
                .padding(.trailing, 9)
                .padding(.top, 27)
                .foregroundColor(searchText.isEmpty ? Color.gray.opacity(0.3) : Color.ocean)
        }
        .padding(.horizontal)
    }
}
