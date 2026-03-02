//
//  CreatePostView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI
import MapKit

struct CreatePostView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var mapViewModel: MapViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var searchService = RestaurantSearchService()
    @State private var restaurantName = ""
    @State private var address = ""
    @State private var selectedRestaurant: RestaurantResult?
    @State private var selectedTimeSlot = TimeSlot.lunch
    @State private var selectedTransportation = Transportation.ownCar
    @State private var customTransportation = ""
    @State private var notes = ""
    @State private var isSubmitting = false
    @State private var errorMessage = ""
    @State private var showingSearchResults = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.uclaLightBlue.opacity(0.4),
                        Color.uclaBlue.opacity(0.1),
                        Color.uclaLightGold.opacity(0.4),
                        Color.uclaGold.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.uclaGold)
                            
                            Text("Create Dining Post")
                                .font(.roboto(24, weight: .bold))
                                .foregroundColor(.uclaDarkBlue)
                        }
                        .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Restaurant Details")
                                .font(.roboto(16, weight: .semibold))
                                .foregroundColor(.uclaDarkBlue)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                TextField("Restaurant Name", text: $restaurantName)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    .onChange(of: restaurantName) { newValue in
                                        if !newValue.isEmpty {
                                            searchService.searchRestaurants(
                                                query: newValue,
                                                near: mapViewModel.region.center
                                            )
                                            showingSearchResults = true
                                        } else {
                                            showingSearchResults = false
                                        }
                                    }
                                
                                if showingSearchResults && !searchService.searchResults.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(searchService.searchResults) { result in
                                            Button(action: {
                                                selectRestaurant(result)
                                            }) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(result.name)
                                                        .font(.roboto(15))
                                                        .foregroundColor(.primary)
                                                    Text(result.address)
                                                        .font(.roboto(12))
                                                        .foregroundColor(.gray)
                                                }
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 12)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            if result.id != searchService.searchResults.last?.id {
                                                Divider()
                                            }
                                        }
                                    }
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                                
                                TextField("Address", text: $address)
                                    .padding()
                                    .background(selectedRestaurant != nil ? Color.gray.opacity(0.1) : Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    .disabled(selectedRestaurant != nil)
                                
                                if selectedRestaurant != nil {
                                    Button(action: clearSelection) {
                                        HStack {
                                            Image(systemName: "xmark.circle.fill")
                                            Text("Clear selection")
                                        }
                                        .font(.roboto(13))
                                        .foregroundColor(.uclaBlue)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(15)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Time Slot")
                                .font(.roboto(16, weight: .semibold))
                                .foregroundColor(.uclaDarkBlue)
                            
                            Picker("When do you want to dine?", selection: $selectedTimeSlot) {
                                ForEach(TimeSlot.allCases, id: \.self) { slot in
                                    Text(slot.rawValue).tag(slot)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(height: 120)
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(15)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Transportation")
                                .font(.roboto(16, weight: .semibold))
                                .foregroundColor(.uclaDarkBlue)
                            
                            VStack(spacing: 10) {
                                ForEach(Transportation.allCases, id: \.self) { transport in
                                    TransportationOptionButton(
                                        transportation: transport,
                                        isSelected: selectedTransportation == transport,
                                        action: {
                                            selectedTransportation = transport
                                        }
                                    )
                                }
                                
                                if selectedTransportation == .others {
                                    TextField("Please specify", text: $customTransportation)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(15)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Additional Notes")
                                .font(.roboto(16, weight: .semibold))
                                .foregroundColor(.uclaDarkBlue)
                            
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                            
                            Text("Share dietary restrictions, preferences, or other info")
                                .font(.roboto(12))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(15)
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.roboto(13))
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        Button(action: submitPost) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Create Post")
                                    .font(.roboto(16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.uclaBlue, Color.uclaDarkBlue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .uclaBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        .disabled(isSubmitting)
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.uclaBlue)
                }
            }
        }
        .accentColor(.uclaBlue)
    }
    
    private func selectRestaurant(_ result: RestaurantResult) {
        selectedRestaurant = result
        restaurantName = result.name
        address = result.address
        showingSearchResults = false
    }
    
    private func clearSelection() {
        selectedRestaurant = nil
        restaurantName = ""
        address = ""
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
        
        let category = selectedRestaurant?.category
        let transportation = selectedTransportation == .others && !customTransportation.isEmpty ? 
            customTransportation : selectedTransportation.rawValue
        
        if let selected = selectedRestaurant {
            mapViewModel.createPostWithCoordinate(
                userId: user.id ?? "",
                username: user.username,
                grade: user.grade,
                gender: user.gender,
                restaurantName: restaurantName,
                address: address,
                coordinate: selected.coordinate,
                timeSlot: selectedTimeSlot.rawValue,
                notes: notes,
                category: category,
                transportation: transportation
            ) { success in
                isSubmitting = false
                if success {
                    dismiss()
                } else {
                    errorMessage = mapViewModel.errorMessage
                }
            }
        } else {
            mapViewModel.createPost(
                userId: user.id ?? "",
                username: user.username,
                grade: user.grade,
                gender: user.gender,
                restaurantName: restaurantName,
                address: address,
                timeSlot: selectedTimeSlot.rawValue,
                notes: notes,
                category: category,
                transportation: transportation
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
}

struct TransportationOptionButton: View {
    let transportation: Transportation
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.uclaBlue.opacity(0.1) : Color.gray.opacity(0.05))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: transportation.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .uclaBlue : .gray)
                }
                
                Text(transportation.rawValue)
                    .font(.roboto(15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .uclaDarkBlue : .gray)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.uclaBlue)
                        .font(.system(size: 22))
                }
            }
            .padding()
            .background(transportationBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.uclaBlue : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var transportationBackground: some View {
        Group {
            if isSelected {
                LinearGradient(
                    gradient: Gradient(colors: [Color.uclaLightBlue.opacity(0.15), Color.uclaLightGold.opacity(0.1)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.white]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }
}
