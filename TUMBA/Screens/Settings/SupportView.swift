//
//  SupportView.swift
//  TUMBA
//
//  Created by Patima Imanalieva on 13.05.2025.
//

import SwiftUI

struct SupportView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                aboutSupportSection
                contactSection
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.leading, 10)
        }
        .navigationBarTitle("Поддержка", displayMode: .inline)
        .background(Color.white)
    }
    
    // MARK: - Компоненты
    
    private var aboutSupportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "О поддержке")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Если у вас возникли какие-либо вопросы или проблемы, свяжитесь с нами через Telegram.")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                
                Text("Мы отвечаем в течение 24 часов.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Сервис поддержки")
            
            Button(action: {
                viewModel.openTelegram()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.ocean)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Написать в Telegram")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("@tumba_support")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
            }
        }
    }
}
