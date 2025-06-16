//
//  CampassView.swift
//  QiblaFinder
//
//  Created by Muhammad Akbar on 17/06/2025.
//

import SwiftUI
import MapKit

struct CompassView: View {
    @Binding var qiblaDirection: CLLocationDirection
    @Binding var heading: CLLocationDirection
    @Binding var headingString: String
    
    var body: some View {
        VStack {
            Text("Qibla Direction")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            ZStack {
                // Compass background
                Circle()
                    .fill(Color(.systemBackground))
                    .shadow(radius: 5)
                    .frame(width: 200, height: 200)
                
                // Compass markings
                ForEach(0..<36) { index in
                    let angle = Double(index) * 10
                    let markerLength: CGFloat = index % 3 == 0 ? 20 : 10
                    
                    Capsule()
                        .fill(index % 3 == 0 ? Color.red : Color.gray)
                        .frame(width: 2, height: markerLength)
                        .offset(y: -90)
                        .rotationEffect(.degrees(angle))
                }
                
                // Qibla indicator
                Image(systemName: "location.north.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundColor(.green)
                    .offset(y: -50)
                    .rotationEffect(.degrees(qiblaDirection - heading))
                
                // Current heading indicator
                Image(systemName: "arrowtriangle.up.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundColor(.blue)
                    .offset(y: -70)
            }
            .rotationEffect(.degrees(-heading))
            
            Text(headingString)
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top, 20)
            
            HStack {
                Image(systemName: "location.north.fill")
                    .foregroundColor(.green)
                Text("Qibla Direction")
                    .font(.caption)
                
                Spacer()
                
                Image(systemName: "arrowtriangle.up.fill")
                    .foregroundColor(.blue)
                Text("Your Heading")
                    .font(.caption)
            }
            .padding()
        }
        .frame(width: UIScreen.main.bounds.width - 60)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

