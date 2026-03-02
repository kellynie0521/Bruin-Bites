//
//  PostDetailView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI
import CoreLocation

struct PostDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var requestViewModel: RequestViewModel
    @Environment(\.dismiss) var dismiss
    
    let post: DiningPost
    let userLocation: CLLocation?
    @State private var showUserProfile = false
    @State private var userToShow: User?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(spacing: 15) {
                            Image(systemName: post.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                                .foregroundColor(.uclaBlue)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(post.restaurantName)
                                    .font(.roboto(22, weight: .bold))
                                    .foregroundColor(.uclaDarkBlue)
                                
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.caption)
                                        .foregroundColor(.uclaGold)
                                    Text(post.timeSlot)
                                        .font(.roboto(13))
                                        .foregroundColor(.gray)
                                }
                                
                                if let distance = post.distance(from: userLocation) {
                                    HStack {
                                        Image(systemName: "location.fill")
                                            .font(.caption)
                                            .foregroundColor(.uclaGold)
                                        Text(distance + " away")
                                            .font(.roboto(13, weight: .semibold))
                                            .foregroundColor(.uclaBlue)
                                    }
                                }
                            }
                            Spacer()
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.uclaBlue)
                                Text(post.address)
                                    .font(.roboto(14))
                            }
                            
                            if let transportation = post.transportation {
                                HStack {
                                    Image(systemName: post.transportationIcon)
                                        .foregroundColor(.uclaGold)
                                    Text(transportation)
                                        .font(.roboto(14, weight: .semibold))
                                        .foregroundColor(.uclaDarkBlue)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.uclaGold.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            if let website = post.restaurantWebsite {
                                Link(destination: URL(string: website)!) {
                                    HStack {
                                        Image(systemName: "link.circle.fill")
                                            .foregroundColor(.uclaBlue)
                                        Text("Visit Website")
                                            .font(.roboto(14))
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.uclaLightBlue.opacity(0.2), Color.uclaLightGold.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    if post.userId != authViewModel.user?.id {
                        Button(action: {
                            loadUserAndShowProfile()
                        }) {
                            HStack(spacing: 15) {
                                AvatarView(username: post.username, size: 50)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Posted by")
                                        .font(.roboto(12))
                                        .foregroundColor(.gray)
                                    
                                    Text(post.username)
                                        .font(.roboto(18, weight: .semibold))
                                        .foregroundColor(.uclaDarkBlue)
                                    
                                    HStack(spacing: 8) {
                                        Text(post.grade)
                                        Text("•")
                                        Text(post.gender)
                                    }
                                    .font(.roboto(12))
                                    .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.uclaBlue)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        HStack(spacing: 15) {
                            AvatarView(username: post.username, size: 50)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Your Post")
                                    .font(.roboto(12))
                                    .foregroundColor(.gray)
                                
                                Text(post.username)
                                    .font(.roboto(18, weight: .semibold))
                                    .foregroundColor(.uclaDarkBlue)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.uclaLightGold.opacity(0.2))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    if !post.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.uclaBlue)
                                Text("Additional Notes")
                                    .font(.roboto(16, weight: .semibold))
                                    .foregroundColor(.uclaDarkBlue)
                            }
                            
                            Text(post.notes)
                                .font(.roboto(14))
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color.uclaLightGold.opacity(0.15))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Post Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.uclaBlue)
                }
            }
            .fullScreenCover(item: $userToShow) { profileUser in
                if let currentUser = authViewModel.user {
                    NavigationView {
                        UserProfileFullView(
                            user: profileUser,
                            postId: post.id ?? "",
                            restaurantName: post.restaurantName,
                            timeSlot: post.timeSlot,
                            currentUser: currentUser,
                            requestViewModel: requestViewModel
                        )
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Back") {
                                    userToShow = nil
                                }
                                .foregroundColor(.uclaBlue)
                            }
                        }
                    }
                }
            }
        }
        .accentColor(.uclaBlue)
    }
    
    private func loadUserAndShowProfile() {
        print("🔵 Starting to load user profile for userId: \(post.userId)")
        let db = Firestore.firestore()
        db.collection("users").document(post.userId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Firestore error: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("❌ No snapshot or document doesn't exist")
                return
            }
            
            do {
                let loadedUser = try snapshot.data(as: User.self)
                print("✅ Successfully decoded user: \(loadedUser.username)")
                
                DispatchQueue.main.async {
                    self.userToShow = loadedUser
                    print("✅ Set userToShow - will trigger fullScreenCover")
                }
            } catch {
                print("❌ Error decoding user: \(error)")
            }
        }
    }
}

struct UserProfileFullView: View {
    let user: User
    let postId: String
    let restaurantName: String
    let timeSlot: String
    let currentUser: User
    let requestViewModel: RequestViewModel
    
    @State private var showRequestDialog = false
    @State private var requestMessage = ""
    @State private var showSuccessAlert = false
    @State private var isSending = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.uclaBlue)
                    
                    Text(user.username)
                        .font(.roboto(28, weight: .bold))
                        .foregroundColor(.uclaDarkBlue)
                }
                .padding(.top, 30)
                
                VStack(spacing: 20) {
                    ProfileInfoCard(
                        icon: "graduationcap.fill",
                        title: "Grade",
                        value: user.grade
                    )
                    
                    ProfileInfoCard(
                        icon: "person.2.fill",
                        title: "Gender",
                        value: user.gender
                    )
                    
                    ProfileInfoCard(
                        icon: "envelope.fill",
                        title: "Email",
                        value: user.email
                    )
                }
                .padding(.horizontal)
                
                Button(action: {
                    showRequestDialog = true
                }) {
                    HStack {
                        Image(systemName: "fork.knife")
                        Text("Send Dining Request")
                    }
                    .font(.roboto(16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.uclaBlue, Color.uclaDarkBlue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: .uclaBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .disabled(isSending)
            }
            .padding(.bottom, 30)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.uclaLightBlue.opacity(0.1), Color.uclaLightGold.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRequestDialog) {
            RequestDialogView(
                toUsername: user.username,
                restaurantName: restaurantName,
                timeSlot: timeSlot,
                requestMessage: $requestMessage,
                onSend: {
                    sendRequest()
                },
                onCancel: {
                    showRequestDialog = false
                }
            )
        }
        .alert("Request Sent!", isPresented: $showSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Your dining request has been sent to \(user.username). You can track it in your inbox.")
        }
    }
    
    private func sendRequest() {
        isSending = true
        requestViewModel.sendDiningRequest(
            fromUserId: currentUser.id ?? "",
            fromUsername: currentUser.username,
            toUserId: user.id ?? "",
            toUsername: user.username,
            postId: postId,
            restaurantName: restaurantName,
            timeSlot: timeSlot,
            message: requestMessage.isEmpty ? nil : requestMessage
        ) { success in
            isSending = false
            showRequestDialog = false
            if success {
                showSuccessAlert = true
            }
        }
    }
}

import FirebaseFirestore
