import Foundation
import SwiftUI

struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label.uppercased())
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundColor(Color.Custom.gray.opacity(0.5))
                .padding(.horizontal, 3)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 3))
                    .frame(width: 343, alignment: .leading)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(isFocused ? Color.Custom.dust : Color.Custom.gray.opacity(0.5)), alignment: .bottom
                    )
                    .autocapitalization(.none)
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                    .foregroundColor(Color.Custom.gray)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 3))
                    .frame(width: 343, alignment: .leading)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(isFocused ? Color.Custom.dust : Color.Custom.gray.opacity(0.5)), alignment: .bottom
                    )
                    .autocapitalization(.none)
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                    .foregroundColor(Color.Custom.gray)
                    .focused($isFocused)
            }
        }
        .padding(.bottom, 15)
    }
}

