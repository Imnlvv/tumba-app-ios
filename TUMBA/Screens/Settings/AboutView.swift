//
//  AboutView.swift
//  TUMBA
//
//  Created by Patima Imanalieva on 13.05.2025.
//

import SwiftUI
import MapKit

struct AboutView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7544, longitude: 37.6484),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                aboutProjectSection
                teamSection
                websiteSection
                addressSection
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.leading, 10)
        }
        .navigationBarTitle("TUMBA", displayMode: .inline)
        .background(Color.white)
    }
    
    // MARK: - Компоненты
    
    private var aboutProjectSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "О проекте")
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.appName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
    }
    
    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Наша команда")
            
            VStack(spacing: 12) {
                ForEach(viewModel.teamContacts, id: \.self) { contact in
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.ocean)
                            .font(.system(size: 20))
                        
                        Text(contact)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    
                    if contact != viewModel.teamContacts.last {
                        Divider()
                            .background(Color.gray.opacity(0.1))
                    }
                }
            }
            .padding()
            .background(Color.white)
        }
    }
    
    private var websiteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Сайт проекта")
            
            Button(action: {
                viewModel.openProjectWebsite()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                    
                    Text("tumba.com")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
            }
        }
    }
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Мы на карте")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("TUMBA")
                    .font(.system(size: 16, weight: .medium))
                
                Text("Москва, Покровский бульвар, 11с10")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            
            Map(
                coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: false,
                annotationItems: [viewModel.hseLocation],
                annotationContent: { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        MapPinView()
                    }
                }
            )
            .frame(height: 250)
            .padding(.top, 8)
            
            Button(action: {
                let url = URL(string: "maps://?ll=55.7544,37.6484&q=ВШЭ")!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Открыть в Картах")
                    .font(.system(size: 14))
                    .foregroundColor(.ocean)
            }
            .padding(.top, 8)
        }
        .padding(.bottom, 20)
    }
}
