//
//  ContentView.swift
//  QiblaFinder
//
//  Created by Muhammad Akbar on 16/06/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct QiblaMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var mapView = MKMapView()
    @State private var isQiblaView = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapViewRepresentable(mapView: $mapView, locationManager: locationManager)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 12) {
                Button(action: toggleQiblaView) {
                    Label("Qibla View", systemImage: "location.north.line")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                Button(action: centerUserLocation) {
                    Label("My Location", systemImage: "location")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
            .padding()
        }
        .onAppear {
            locationManager.checkLocationPermissions()
            locationManager.startTracking(mapView: mapView)
        }
    }

    private func toggleQiblaView() {
        isQiblaView.toggle()
        locationManager.updatePolyline(on: mapView)

        if let userLoc = locationManager.userLocation?.coordinate {
            let qiblaCoord = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)

            if isQiblaView {
                /// Disable heading updates for Qibla View
                locationManager.stopHeadingUpdates()
                let bounds = MKMapRect(coordinates: [userLoc, qiblaCoord])
                mapView.setVisibleMapRect(bounds, edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 80, right: 40), animated: true)
            } else {
                /// Re-enable heading updates when leaving Qibla View
                locationManager.startHeadingUpdates()
                let region = MKCoordinateRegion(center: userLoc, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            }
        }
    }

    private func centerUserLocation() {
        if let userCoord = locationManager.userLocation?.coordinate {
            locationManager.startHeadingUpdates()
            let region = MKCoordinateRegion(center: userCoord, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
}

