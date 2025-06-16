//
//  Double.swift
//  QiblaFinder
//
//  Created by Muhammad Akbar on 17/06/2025.
//

import Foundation

extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}
