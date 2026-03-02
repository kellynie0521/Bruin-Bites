//
//  ProfileView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.uclaBlue, Color.uclaDarkBlue, Color.uclaGold.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 250)
                    
                    VStack(spacing: 20) {
                        if let user = authViewModel.user {
                            AvatarView(username: user.username, size: 100)
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        
                        if let user = authViewModel.user {
                            Text(user.username)
                                .font(.roboto(28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(user.email)
                                .font(.roboto(14))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.top, 40)
                }
                
                VStack(spacing: 20) {
                    if let user = authViewModel.user {
                        HStack(spacing: 15) {
                            ProfileInfoBadge(
                                icon: "graduationcap.fill",
                                title: user.grade,
                                color: .uclaBlue
                            )
                            
                            ProfileInfoBadge(
                                icon: "person.2.fill",
                                title: user.gender,
                                color: .uclaGold
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    
                    VStack(spacing: 15) {
                        ProfileMenuButton(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Log Out",
                            subtitle: "Sign out of your account",
                            color: .red,
                            action: {
                                authViewModel.logout()
                            }
                        )
                    }
                    .padding()
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.uclaLightBlue.opacity(0.1), Color.uclaLightGold.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct ProfileInfoBadge: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
            Text(title)
                .font(.roboto(15, weight: .semibold))
                .foregroundColor(.uclaDarkBlue)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ProfileMenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 22))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.roboto(17, weight: .semibold))
                        .foregroundColor(.uclaDarkBlue)
                    
                    Text(subtitle)
                        .font(.roboto(13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
