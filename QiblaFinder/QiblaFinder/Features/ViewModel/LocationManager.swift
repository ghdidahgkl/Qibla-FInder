//
//  LocationManager.swift
//  QiblaFinder
//
//  Created by Muhammad Akbar on 17/06/2025.
//

import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    let kaabaLocation = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var qiblaDirection: CLLocationDirection = 0
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var heading: CLLocationDirection = 0
    @Published var headingString: String = ""
    @Published var errorMessage: String?
    @Published var showPermissionAlert = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus()
    }
    
    func zoomToUserLocation() {
        guard let userLocation = userLocation else {
            requestLocation()
            return
        }
        
        DispatchQueue.main.async {
            withAnimation {
                self.region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                )
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        authorizationStatus = status
        handleAuthorizationStatus(status)
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationServices()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable in Settings."
            showPermissionAlert = true
        @unknown default:
            errorMessage = "Unknown authorization status"
            showPermissionAlert = true
        }
    }
    
    private func startLocationServices() {
        // Check authorization status first
        let status = locationManager.authorizationStatus
        
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            // Don't start services if not authorized
            return
        }
        
        // Start services on background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
                
                if CLLocationManager.headingAvailable() {
                    self.locationManager.startUpdatingHeading()
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Compass not available on this device"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Location services are disabled"
                }
            }
        }
    }

    // Then modify locationManagerDidChangeAuthorization to call this:
    
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            errorMessage = "Location access required"
            showPermissionAlert = true
            return
        }
        
        locationManager.requestLocation()
    }
    
    private func updateRegion(to coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            withAnimation {
                self.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                )
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let status = manager.authorizationStatus
            self.authorizationStatus = status
            
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.startLocationServices()
            case .denied, .restricted:
                self.errorMessage = "Location access denied. Please enable in Settings."
                self.showPermissionAlert = true
            case .notDetermined:
                break // Waiting for user decision
            @unknown default:
                self.errorMessage = "Unknown authorization status"
                self.showPermissionAlert = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        updateRegion(to: location.coordinate)
        calculateQiblaDirection(from: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading
        updateQiblaDirectionWithHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                errorMessage = "Location access denied. Please enable in Settings."
            case .locationUnknown:
                errorMessage = "Unable to determine location"
            case .headingFailure:
                errorMessage = "Compass not available"
            default:
                errorMessage = "Location error: \(clError.localizedDescription)"
            }
        } else {
            errorMessage = error.localizedDescription
        }
        showPermissionAlert = true
    }
    
    private func calculateQiblaDirection(from location: CLLocation) {
        let userLat = location.coordinate.latitude
        let userLon = location.coordinate.longitude
        
        let φ1 = userLat.degreesToRadians
        let φ2 = 21.4225.degreesToRadians
        let λ1 = userLon.degreesToRadians
        let λ2 = 39.8262.degreesToRadians
        
        let y = sin(λ2 - λ1)
        let x = cos(φ1) * tan(φ2) - sin(φ1) * cos(λ2 - λ1)
        let θ = atan2(y, x)
        
        qiblaDirection = (θ.radiansToDegrees).truncatingRemainder(dividingBy: 360)
        if qiblaDirection < 0 {
            qiblaDirection += 360
        }
        updateQiblaDirectionWithHeading()
    }
    
    private func updateQiblaDirectionWithHeading() {
        let relativeDirection = (qiblaDirection - heading).truncatingRemainder(dividingBy: 360)
        headingString = String(format: "%.0f° towards Qibla", relativeDirection < 0 ? relativeDirection + 360 : relativeDirection)
    }
}
