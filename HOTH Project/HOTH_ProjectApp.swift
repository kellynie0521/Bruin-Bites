//
//  HOTH_ProjectApp.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure Firebase only if GoogleService-Info.plist is valid (prevents SIGTERM crash)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        return true
    }
}

@main
struct HOTH_ProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentSwitcher()
                .environmentObject(authViewModel)
        }
    }
}

struct ContentSwitcher: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    var body: some View {
        Group {
            if !hasSeenWelcome {
                WelcomeView(onGetStarted: {
                    hasSeenWelcome = true
                })
            } else if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.default, value: authViewModel.isAuthenticated)
    }
}
