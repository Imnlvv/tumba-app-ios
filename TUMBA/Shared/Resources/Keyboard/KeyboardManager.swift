import Foundation
import SwiftUI
import Combine

final class KeyboardManager: ObservableObject {
    @Published var isVisible = false
    @Published var height: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = KeyboardManager()
    
    private init() {
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification))
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .sink { [weak self] height in
                self?.height = height
                self?.isVisible = height > 0
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.height = 0
                self?.isVisible = false
            }
            .store(in: &cancellables)
    }
    
    func hide() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Модификаторы для View
extension View {
    func keyboardAdaptive() -> some View {
        modifier(KeyboardAdaptiveModifier())
    }
    
    func hideKeyboardOnTap() -> some View {
        modifier(HideKeyboardModifier())
    }
}

struct KeyboardAdaptiveModifier: ViewModifier {
    @StateObject private var keyboard = KeyboardManager.shared
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboard.height)
            .animation(.easeOut(duration: 0.25), value: keyboard.height)
    }
}

struct HideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                KeyboardManager.shared.hide()
            }
    }
}

// MARK: - Утилиты для TextField
extension View {
    func withKeyboardToolbar(doneAction: (() -> Void)? = nil) -> some View {
        modifier(KeyboardToolbarModifier(doneAction: doneAction))
    }
}

struct KeyboardToolbarModifier: ViewModifier {
    var doneAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        doneAction?()
                        KeyboardManager.shared.hide()
                    }
                }
            }
    }
}

extension View {
    func keyboardAwarePadding() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier())
    }
}

struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
    }
}
