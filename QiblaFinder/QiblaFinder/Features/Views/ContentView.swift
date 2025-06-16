//
//  ContentView.swift
//  QiblaFinder
//
//  Created by Muhammad Akbar on 16/06/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showFullPath = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                QiblaMapView(
                    region: $locationManager.region,
                    qiblaDirection: $locationManager.qiblaDirection,
                    showFullPath: $showFullPath,
                    userLocation: $locationManager.userLocation
                )
                
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showFullPath.toggle()
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: showFullPath ? "location.fill" : "location.north.fill")
                                .font(.title)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                            Text(showFullPath ? "Hide full path" : "Show full path")
                                .font(.caption2)
                                .foregroundColor(.black)
                        }
                    }
                    
                    Button(action: {
                        locationManager.zoomToUserLocation()
                        withAnimation {
                            showFullPath = false
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.title)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                            Text("Zoom to Me")
                                .font(.caption2)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0 + 20)
                .padding(.trailing, 20)
            }
            
            CompassView(
                qiblaDirection: $locationManager.qiblaDirection,
                heading: $locationManager.heading,
                headingString: $locationManager.headingString
            )
            .frame(height: UIScreen.main.bounds.height / 2)
        }
    }
    
    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else { return }
        UIApplication.shared.open(settingsURL)
    }
}

#Preview {
    ContentView()
}



