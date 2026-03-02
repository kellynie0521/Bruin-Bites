//
//  MainTabView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI
import MapKit

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var requestViewModel = RequestViewModel()
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var selectedTab = 0
    
    init() {
        // 配置 TabBar 外观
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapViewWrapper(requestViewModel: requestViewModel, chatViewModel: chatViewModel)
                .environmentObject(authViewModel)
                .tabItem {
                    Image(systemName: "map.fill")
                        .font(.system(size: 20))
                    Text("Map")
                        .font(.roboto(10))
                }
                .tag(0)
            
            CreatePostTabView()
                .environmentObject(authViewModel)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Create")
                        .font(.roboto(10))
                }
                .tag(1)
            
            Group {
                if unreadCount > 0 {
                    InboxViewWrapper(
                        requestViewModel: requestViewModel,
                        chatViewModel: chatViewModel
                    )
                    .environmentObject(authViewModel)
                    .badge(unreadCount)
                } else {
                    InboxViewWrapper(
                        requestViewModel: requestViewModel,
                        chatViewModel: chatViewModel
                    )
                    .environmentObject(authViewModel)
                }
            }
            .tabItem {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 20))
                Text("Messages")
                    .font(.roboto(10))
            }
            .tag(2)
            
            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                    Text("Profile")
                        .font(.roboto(10))
                }
                .tag(3)
        }
        .accentColor(.uclaBlue)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if let userId = authViewModel.user?.id {
                requestViewModel.fetchReceivedRequests(userId: userId)
                chatViewModel.fetchConversations(userId: userId)
            }
        }
    }
    
    // 计算未读数量
    private var unreadCount: Int {
        let pendingRequests = requestViewModel.receivedRequests.filter { $0.requestStatus == .pending }.count
        let unreadMessages = chatViewModel.conversations.filter { $0.hasUnreadMessages ?? false }.count
        let total = pendingRequests + unreadMessages
        return total > 0 ? total : 0
    }
}

struct InboxViewWrapper: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var requestViewModel: RequestViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    
    var body: some View {
        InboxViewShared(
            requestViewModel: requestViewModel,
            chatViewModel: chatViewModel
        )
        .environmentObject(authViewModel)
    }
}

struct MapViewWrapper: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var requestViewModel: RequestViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    @StateObject private var mapViewModel = MapViewModel()
    @State private var selectedPost: DiningPost?
    @State private var showLocationPermissionPrompt = false
    @State private var hasShownPermissionPrompt = false
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $mapViewModel.region, 
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: mapViewModel.posts) { post in
                MapAnnotation(coordinate: post.coordinate) {
                    Button(action: {
                        selectedPost = post
                        print("📍 Selected post: \(post.restaurantName)")
                    }) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 40, height: 40)
                                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                                
                                Image(systemName: post.iconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.uclaBlue)
                            }
                            
                            VStack(spacing: 2) {
                                Text(post.restaurantName)
                                    .font(.roboto(11, weight: .bold))
                                    .foregroundColor(.uclaDarkBlue)
                                    .lineLimit(1)
                                
                                if let distance = post.distance(from: mapViewModel.userLocation) {
                                    HStack(spacing: 3) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 8))
                                            .foregroundColor(.uclaGold)
                                        Text(distance)
                                            .font(.roboto(10, weight: .medium))
                                            .foregroundColor(.uclaGold)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.95))
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(item: $selectedPost) { post in
            PostDetailView(requestViewModel: requestViewModel, post: post, userLocation: mapViewModel.userLocation)
                .environmentObject(authViewModel)
        }
        .fullScreenCover(isPresented: $showLocationPermissionPrompt) {
            LocationPermissionView(
                onAllow: {
                    print("🟢 User tapped 'Allow' on custom permission screen")
                    showLocationPermissionPrompt = false
                    mapViewModel.requestLocationPermission()
                },
                onSkip: {
                    print("🟡 User tapped 'Maybe Later' on custom permission screen")
                    showLocationPermissionPrompt = false
                    hasShownPermissionPrompt = true
                }
            )
        }
        .task {
            // 使用 task 替代 onAppear 避免 "Publishing changes" 警告
            print("🔵 MapView appeared, authorization status: \(mapViewModel.locationAuthorizationStatus.rawValue)")
            print("📊 Number of posts loaded: \(mapViewModel.posts.count)")
            print("📍 Current user location: \(mapViewModel.userLocation?.coordinate.latitude ?? 0), \(mapViewModel.userLocation?.coordinate.longitude ?? 0)")
            
            // 打印所有 posts 的信息
            for (index, post) in mapViewModel.posts.enumerated() {
                let distanceStr = post.distance(from: mapViewModel.userLocation) ?? "unknown"
                print("  Post \(index + 1): \(post.restaurantName) at (\(post.latitude), \(post.longitude)), distance: \(distanceStr)")
            }
            
            // 第一次打开地图时，如果位置权限未确定，显示友好的提示
            if mapViewModel.locationAuthorizationStatus == .notDetermined && !hasShownPermissionPrompt {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 秒
                showLocationPermissionPrompt = true
                hasShownPermissionPrompt = true
            } else if mapViewModel.locationAuthorizationStatus == .authorizedWhenInUse || mapViewModel.locationAuthorizationStatus == .authorizedAlways {
                print("✅ Already authorized, starting location updates")
                mapViewModel.startLocationUpdates()
            } else {
                print("⚠️ Location permission denied or restricted")
            }
        }
    }
}

struct CreatePostTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var mapViewModel = MapViewModel()
    
    var body: some View {
        CreatePostView(mapViewModel: mapViewModel)
            .environmentObject(authViewModel)
    }
}
