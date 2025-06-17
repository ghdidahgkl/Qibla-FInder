//
//  MapKitRect.swift
//  QiblaFinder
//
//  Created by Muhammad Akbar on 17/06/2025.

import MapKit

extension MKMapRect {
    init(coordinates: [CLLocationCoordinate2D]) {
        self = coordinates.reduce(MKMapRect.null) { (rect, coord) in
            let point = MKMapPoint(coord)
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
            return rect.union(pointRect)
        }
    }
}
