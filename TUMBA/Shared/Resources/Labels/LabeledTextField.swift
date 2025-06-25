import SwiftUI

struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    @FocusState private var isFocused: Bool
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label.uppercased())
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray.opacity(0.5))
                .padding(.horizontal, 3)
            
            ZStack(alignment: .trailing) {
                // Основное поле ввода
                Group {
                    if isSecure && !showPassword {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: isSecure ? 30 : 3))
                .frame(width: 343, alignment: .leading)
                .autocapitalization(.none)
                .font(.system(size: 16))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray)
                .focused($isFocused)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(isFocused ? Color.Custom.dust : Color.Custom.gray.opacity(0.5)),
                    alignment: .bottom
                )
                
                // Кнопка переключения видимости
                if isSecure {
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(Color.Custom.gray.opacity(0.5))
                    }
                    .padding(.trailing, 5)
                    .offset(y: -5)
                }
            }
            .frame(width: 343)
        }
        .padding(.bottom, 15)
    }
}
