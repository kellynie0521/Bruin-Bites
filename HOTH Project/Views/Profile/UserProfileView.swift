//
//  UserProfileView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI

struct UserProfileView: View {
    let user: User
    let postId: String
    let restaurantName: String
    let timeSlot: String
    let currentUser: User
    let requestViewModel: RequestViewModel
    
    @Environment(\.dismiss) var dismiss
    @State private var showRequestDialog = false
    @State private var requestMessage = ""
    @State private var showSuccessAlert = false
    @State private var isSending = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 15) {
                        AvatarView(username: user.username, size: 100)
                            .overlay(Circle().stroke(Color.uclaBlue.opacity(0.3), lineWidth: 3))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.uclaBlue)
                }
            }
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
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your dining request has been sent to \(user.username). You can track it in your inbox.")
            }
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

struct RequestDialogView: View {
    let toUsername: String
    let restaurantName: String
    let timeSlot: String
    @Binding var requestMessage: String
    let onSend: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "fork.knife.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.uclaBlue)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Dining Request")
                                .font(.roboto(20, weight: .bold))
                                .foregroundColor(.uclaDarkBlue)
                            Text("to \(toUsername)")
                                .font(.roboto(14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label(restaurantName, systemImage: "location.fill")
                            .font(.roboto(15))
                            .foregroundColor(.uclaDarkBlue)
                        Label(timeSlot, systemImage: "clock.fill")
                            .font(.roboto(13))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.uclaLightBlue.opacity(0.1))
                .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add a message (optional)")
                        .font(.roboto(14, weight: .semibold))
                        .foregroundColor(.uclaDarkBlue)
                    
                    TextEditor(text: $requestMessage)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Text("Introduce yourself or share why you'd like to dine together")
                        .font(.roboto(11))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.roboto(16, weight: .semibold))
                            .foregroundColor(.uclaBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.uclaBlue, lineWidth: 2)
                            )
                            .cornerRadius(12)
                    }
                    
                    Button(action: onSend) {
                        Text("Send Request")
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
                            .cornerRadius(12)
                            .shadow(color: .uclaBlue.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .padding()
            .navigationTitle("Send Request")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileInfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(.uclaBlue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.roboto(12))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.roboto(16, weight: .semibold))
                    .foregroundColor(.uclaDarkBlue)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
