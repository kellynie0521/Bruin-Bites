//
//  WelcomeView.swift
//  HOTH Project
//
//  Created by Assistant
//

import SwiftUI

struct WelcomeView: View {
    let onGetStarted: () -> Void
    @State private var showLogin = false
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.uclaBlue,
                    Color.uclaDarkBlue,
                    Color.uclaGold.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // UCLA 熊熊封面图片
                Image("AppCover")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 40)
                
                // App 名称和标语
                VStack(spacing: 12) {
                    Text("BruinBites")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Find Your Perfect Dining Companion")
                        .font(.roboto(18))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // 特性展示
                VStack(spacing: 15) {
                    WelcomeFeature(icon: "map.fill", text: "Discover dining spots on campus")
                    WelcomeFeature(icon: "person.2.fill", text: "Connect with fellow Bruins")
                    WelcomeFeature(icon: "message.fill", text: "Chat and plan meals together")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // 开始按钮
                Button(action: {
                    onGetStarted()
                }) {
                    HStack(spacing: 12) {
                        Text("Get Started")
                            .font(.roboto(20, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.uclaBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

struct WelcomeFeature: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.uclaGold)
                .frame(width: 30)
            
            Text(text)
                .font(.roboto(15))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    WelcomeView(onGetStarted: {
        print("Get Started tapped")
    })
}
