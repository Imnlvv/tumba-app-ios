import SwiftUI
import MapKit

//  Общие компоненты для всех экранов

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.gray)
            .padding(.leading, 4)
    }
}

struct SettingsRow: View {
    let title: String
    let value: String?
    let isNavigation: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            if isNavigation {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
    }
}

struct MapPinView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.ocean.opacity(0.2))
                .frame(width: 32, height: 32)
            
            Circle()
                .fill(Color.ocean)
                .frame(width: 20, height: 20)
            
            Image(systemName: "building.2.fill")
                .foregroundColor(.white)
                .font(.system(size: 8))
        }
    }
}
