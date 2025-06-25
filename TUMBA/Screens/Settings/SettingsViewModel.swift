//
//  SettingsViewModel.swift
//  TUMBA
//
//  Created by Patima Imanalieva on 13.05.2025.
//

import SwiftUI
import MapKit

class SettingsViewModel: ObservableObject {
    // Навигация
    @Published var showingAbout = false
    @Published var showingSupport = false
    
    // О приложении
    let appName = "Интерьерные подбороки с прямыми ссылками на товары"
    let teamContacts = ["@imnlv", "@neamiunis", "@osmium_void"]
    let projectURL = "https://github.com/Imnlvv/Tumba__App"
    
    let hseLocation = Location(
        name: "TUMBA",
        coordinate: CLLocationCoordinate2D(latitude: 55.7544, longitude: 37.6484)
    )
    
    struct Location: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
    }
    
    func openTelegram() {
        let telegramURL = URL(string: "tg://resolve?domain=imnlv")!
        let webURL = URL(string: "https://t.me/imnlv")!
        
        if UIApplication.shared.canOpenURL(telegramURL) {
            UIApplication.shared.open(telegramURL, options: [:]) { success in
                if !success {
                    self.openInSafari(url: webURL)
                }
            }
        } else {
            openInSafari(url: webURL)
        }
    }
    
    private func openInSafari(url: URL) {
        if #available(iOS 15.0, *) {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            scene.open(url, options: nil)
        } else {
            UIApplication.shared.open(url)
        }
    }
    
    func openProjectWebsite() {
        guard let url = URL(string: projectURL) else { return }
        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                print("Ошибка при открытии URL: \(url.absoluteString)")
            }
        }
    }
}
