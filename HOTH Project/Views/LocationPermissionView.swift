//
//  LocationPermissionView.swift
//  HOTH Project
//
//  Created by Assistant
//

import SwiftUI

struct LocationPermissionView: View {
    let onAllow: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.uclaLightBlue.opacity(0.3),
                    Color.uclaBlue.opacity(0.2),
                    Color.uclaLightGold.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.uclaBlue.opacity(0.2), Color.uclaLightBlue.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "location.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.uclaBlue)
                }
                .padding(.bottom, 20)
                
                // Title
                Text("Enable Location")
                    .font(.roboto(32, weight: .bold))
                    .foregroundColor(.uclaDarkBlue)
                    .multilineTextAlignment(.center)
                
                // Description
                VStack(spacing: 15) {
                    FeatureRow(
                        icon: "mappin.and.ellipse",
                        text: "See your location on the map"
                    )
                    
                    FeatureRow(
                        icon: "ruler",
                        text: "Calculate distances to restaurants"
                    )
                    
                    FeatureRow(
                        icon: "person.2.fill",
                        text: "Find dining buddies nearby"
                    )
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: onAllow) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Allow Location Access")
                        }
                        .font(.roboto(18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.uclaBlue, Color.uclaDarkBlue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .uclaBlue.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    
                    Button(action: onSkip) {
                        Text("Maybe Later")
                            .font(.roboto(16, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(.uclaGold)
            
            Text(text)
                .font(.roboto(16))
                .foregroundColor(.uclaDarkBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
