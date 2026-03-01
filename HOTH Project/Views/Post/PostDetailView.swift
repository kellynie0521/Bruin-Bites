//
//  PostDetailView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI

struct PostDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var chatViewModel = ChatViewModel()
    @Environment(\.dismiss) var dismiss
    
    let post: DiningPost
    @State private var showChat = false
    @State private var conversationId: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "fork.knife.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(post.restaurantName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text(post.timeSlot)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label(post.address, systemImage: "location.fill")
                                .font(.body)
                            
                            if let website = post.restaurantWebsite {
                                Link(destination: URL(string: website)!) {
                                    Label("Visit Website", systemImage: "link")
                                        .font(.body)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Posted By")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading) {
                                Text(post.username)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    Text(post.grade)
                                    Text("•")
                                    Text(post.gender)
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    if !post.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes")
                                .font(.headline)
                            
                            Text(post.notes)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    if post.userId != authViewModel.user?.id {
                        Button(action: {
                            connectWithUser()
                        }) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Connect")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Post Details")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
            .navigationDestination(isPresented: $showChat) {
                if let conversationId = conversationId {
                    ChatView(conversationId: conversationId, chatViewModel: chatViewModel)
                        .environmentObject(authViewModel)
                }
            }
        }
    }
    
    private func connectWithUser() {
        guard let currentUser = authViewModel.user else { return }
        
        chatViewModel.createOrGetConversation(
            currentUserId: currentUser.id ?? "",
            currentUsername: currentUser.username,
            postOwnerId: post.userId,
            postOwnerUsername: post.username,
            postId: post.id ?? "",
            restaurantName: post.restaurantName
        ) { convId in
            if let convId = convId {
                conversationId = convId
                showChat = true
            }
        }
    }
}
