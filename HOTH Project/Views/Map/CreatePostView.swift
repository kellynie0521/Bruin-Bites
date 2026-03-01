//
//  CreatePostView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI

struct CreatePostView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var mapViewModel: MapViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var restaurantName = ""
    @State private var address = ""
    @State private var selectedTimeSlot = TimeSlot.lunch
    @State private var notes = ""
    @State private var isSubmitting = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Restaurant Details")) {
                    TextField("Restaurant Name", text: $restaurantName)
                    TextField("Address", text: $address)
                }
                
                Section(header: Text("Time Slot")) {
                    Picker("When do you want to dine?", selection: $selectedTimeSlot) {
                        ForEach(TimeSlot.allCases, id: \.self) { slot in
                            Text(slot.rawValue).tag(slot)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Additional Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                    Text("Share any dietary restrictions, preferences, or other information")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        submitPost()
                    }) {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Create Post")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
            .navigationTitle("Create Dining Post")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
    
    private func submitPost() {
        errorMessage = ""
        
        guard !restaurantName.isEmpty else {
            errorMessage = "Please enter a restaurant name"
            return
        }
        
        guard !address.isEmpty else {
            errorMessage = "Please enter an address"
            return
        }
        
        guard let user = authViewModel.user else {
            errorMessage = "User not found"
            return
        }
        
        isSubmitting = true
        
        mapViewModel.createPost(
            userId: user.id ?? "",
            username: user.username,
            grade: user.grade,
            gender: user.gender,
            restaurantName: restaurantName,
            address: address,
            timeSlot: selectedTimeSlot.rawValue,
            notes: notes
        ) { success in
            isSubmitting = false
            if success {
                dismiss()
            } else {
                errorMessage = mapViewModel.errorMessage
            }
        }
    }
}
