//
//  SettingsView.swift
//  TUMBA
//
//  Created by Patima Imanalieva on 13.05.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 35) {
                    infoSection
                    versionSection
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.leading, 10)
            }
            .navigationBarTitle("Настройки", displayMode: .inline)
            .background(Color.white)
        }
    }
    
    // MARK: - Секции
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Информация")
            
            VStack(spacing: 20) {
                NavigationLink(destination: AboutView(viewModel: viewModel)) {
                    SettingsRow(
                        title: "О нас",
                        value: nil,
                        isNavigation: true
                    )
                }
                
                NavigationLink(destination: SupportView(viewModel: viewModel)) {
                    SettingsRow(
                        title: "Поддержка",
                        value: nil,
                        isNavigation: true
                    )
                }
            }
            .padding()
            .background(Color.white)
        }
    }
    
    private var versionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "О приложении")
            
            VStack(spacing: 12) {
                SettingsRow(
                    title: "Версия",
                    value: "1.0.0",
                    isNavigation: false
                )
            }
            .padding()
            .background(Color.white)
            .padding(.bottom, 30)
        }
    }
}
