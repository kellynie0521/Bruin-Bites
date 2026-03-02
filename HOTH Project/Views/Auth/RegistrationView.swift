//
//  RegistrationView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var selectedGrade = Grade.freshman
    @State private var selectedGender = Gender.preferNotToSay
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.uclaLightBlue.opacity(0.4),
                        Color.uclaLightGold.opacity(0.4),
                        Color.white.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        VStack(spacing: 10) {
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.uclaBlue)
                            
                            Text("Join BruinBites")
                                .font(.roboto(22, weight: .bold))
                                .foregroundColor(.uclaDarkBlue)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Account Information")
                                    .font(.headline)
                                    .foregroundColor(.uclaDarkBlue)
                                
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(.uclaBlue)
                                            .frame(width: 25)
                                        TextField("UCLA Email", text: $email)
                                            .autocapitalization(.none)
                                            .keyboardType(.emailAddress)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    
                                    HStack {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.uclaBlue)
                                            .frame(width: 25)
                                        SecureField("Password", text: $password)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    
                                    HStack {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.uclaBlue)
                                            .frame(width: 25)
                                        SecureField("Confirm Password", text: $confirmPassword)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Profile Information")
                                    .font(.headline)
                                    .foregroundColor(.uclaDarkBlue)
                                
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.uclaBlue)
                                            .frame(width: 25)
                                        TextField("Username", text: $username)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "graduationcap.fill")
                                                .foregroundColor(.uclaBlue)
                                                .frame(width: 25)
                                            Text("Grade")
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Picker("Grade", selection: $selectedGrade) {
                                            ForEach(Grade.allCases, id: \.self) { grade in
                                                Text(grade.rawValue).tag(grade)
                                            }
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                        .background(Color.white)
                                        .cornerRadius(8)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(12)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "person.2.fill")
                                                .foregroundColor(.uclaBlue)
                                                .frame(width: 25)
                                            Text("Gender")
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Picker("Gender", selection: $selectedGender) {
                                            ForEach(Gender.allCases, id: \.self) { gender in
                                                Text(gender.rawValue).tag(gender)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .accentColor(.uclaBlue)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if !authViewModel.errorMessage.isEmpty {
                                Text(authViewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button(action: {
                                validateAndRegister()
                            }) {
                                Text("Create Account")
                                    .fontWeight(.bold)
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
                                    .shadow(color: .uclaBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Register")
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
    
    private func validateAndRegister() {
        errorMessage = ""
        
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard email.lowercased().hasSuffix("@ucla.edu") else {
            errorMessage = "Please use a valid UCLA email address"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        Task {
            await authViewModel.register(
                email: email,
                password: password,
                username: username,
                grade: selectedGrade.rawValue,
                gender: selectedGender.rawValue
            )
            
            if authViewModel.isAuthenticated {
                dismiss()
            }
        }
    }
}
