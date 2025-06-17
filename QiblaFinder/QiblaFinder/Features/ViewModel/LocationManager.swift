//
//  LocationManager.swift
//  QiblaFinder
//
//  Created by Muhammad Akbar on 17/06/2025.

import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var heading: CLHeading?
    weak var mapView: MKMapView?
    private var isUpdatingHeading = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = 1
    }

    func checkLocationPermissions() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    func startTracking(mapView: MKMapView) {
        self.mapView = mapView
        startHeadingUpdates()
    }

    func startHeadingUpdates() {
        guard !isUpdatingHeading else { return }
        manager.startUpdatingHeading()
        isUpdatingHeading = true
    }

    func stopHeadingUpdates() {
        guard isUpdatingHeading else { return }
        manager.stopUpdatingHeading()
        isUpdatingHeading = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            userLocation = loc
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading

        guard let mapView = self.mapView,
              let userCoord = userLocation?.coordinate else { return }

        let camera = MKMapCamera(lookingAtCenter: userCoord,
                                 fromDistance: 1000,
                                 pitch: 0,
                                 heading: newHeading.trueHeading)
        mapView.setCamera(camera, animated: true)

        updatePolyline(on: mapView)
    }

    func updatePolyline(on mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        guard let userLoc = userLocation?.coordinate else { return }
        let kaabaCoord = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)

        let polyline = MKPolyline(coordinates: [userLoc, kaabaCoord], count: 2)
        mapView.addOverlay(polyline)

        let kaabaAnnotation = MKPointAnnotation()
        kaabaAnnotation.coordinate = kaabaCoord
        kaabaAnnotation.title = "Kaaba"

        mapView.addAnnotation(kaabaAnnotation)
    }
}
