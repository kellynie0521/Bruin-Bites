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
            Form {
                Section(header: Text("Account Information")) {
                    TextField("UCLA Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                Section(header: Text("Profile Information")) {
                    TextField("Username", text: $username)
                    
                    Picker("Grade", selection: $selectedGrade) {
                        ForEach(Grade.allCases, id: \.self) { grade in
                            Text(grade.rawValue).tag(grade)
                        }
                    }
                    
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                }
                
                Section {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        validateAndRegister()
                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Register")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
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
