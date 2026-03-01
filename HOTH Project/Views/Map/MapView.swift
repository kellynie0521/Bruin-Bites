//
//  MapView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var mapViewModel = MapViewModel()
    @State private var showCreatePost = false
    @State private var selectedPost: DiningPost?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Map(coordinateRegion: $mapViewModel.region, annotationItems: mapViewModel.posts) { post in
                    MapAnnotation(coordinate: post.coordinate) {
                        Button(action: {
                            selectedPost = post
                        }) {
                            VStack {
                                Image(systemName: "fork.knife.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.red)
                                    .background(Circle().fill(Color.white))
                                
                                Text(post.restaurantName)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .padding(4)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(5)
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showCreatePost = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white))
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            .navigationTitle("Dining Buddy")
            .navigationBarItems(trailing: Button(action: {
                authViewModel.logout()
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
            })
            .sheet(isPresented: $showCreatePost) {
                CreatePostView(mapViewModel: mapViewModel)
                    .environmentObject(authViewModel)
            }
            .sheet(item: $selectedPost) { post in
                PostDetailView(post: post)
                    .environmentObject(authViewModel)
            }
        }
    }
}

struct AnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
