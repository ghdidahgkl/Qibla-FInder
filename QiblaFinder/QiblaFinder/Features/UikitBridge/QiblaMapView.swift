//
//  QiblaMapView.swift
//  QiblaFinder
//
//  Created by Muhammad Akbar on 17/06/2025.
//

import SwiftUI
import MapKit

struct QiblaMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var qiblaDirection: CLLocationDirection
    @Binding var showFullPath: Bool
    @Binding var userLocation: CLLocationCoordinate2D?
    
    let kaabaLocation = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.isRotateEnabled = false
        
        let kaabaAnnotation = MKPointAnnotation()
        kaabaAnnotation.title = "Kaaba"
        kaabaAnnotation.coordinate = kaabaLocation
        mapView.addAnnotation(kaabaAnnotation)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Keep map north-up
        let camera = MKMapCamera(
            lookingAtCenter: userLocation ?? region.center,
            fromDistance: mapView.camera.centerCoordinateDistance,
            pitch: 0,
            heading: 0
        )
        
        UIView.animate(withDuration: 0.5) {
            mapView.setCamera(camera, animated: true)
        }
        
        // Update polyline
        mapView.removeOverlays(mapView.overlays)
        if let userLocation = userLocation {
            let polyline = MKPolyline(coordinates: [userLocation, kaabaLocation], count: 2)
            mapView.addOverlay(polyline)
            
            if showFullPath {
                showBothLocations(mapView: mapView, userLocation: userLocation)
            } else {
                // Zoom to user location with padding
                let padding = UIEdgeInsets(top: 50, left: 50, bottom: 200, right: 50)
                let region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                )
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    private func showBothLocations(mapView: MKMapView, userLocation: CLLocationCoordinate2D) {
        let coordinates = [userLocation, kaabaLocation]
        var zoomRect = MKMapRect.null
        for coordinate in coordinates {
            let point = MKMapPoint(coordinate)
            zoomRect = zoomRect.union(MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1))
        }
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: QiblaMapView
        
        init(_ parent: QiblaMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            let identifier = "Kaaba"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                (annotationView as? MKMarkerAnnotationView)?.glyphImage = UIImage(systemName: "star.fill")
                (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .systemRed
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
}
