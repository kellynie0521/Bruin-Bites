//
//  LoginView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegistration = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.uclaLightBlue,
                        Color.uclaBlue.opacity(0.8),
                        Color.uclaLightGold.opacity(0.7),
                        Color.uclaGold.opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    VStack(spacing: 15) {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.uclaGold)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Text("BruinBites")
                            .font(.roboto(28, weight: .bold))
                            .foregroundColor(.uclaDarkBlue)
                        
                        Text("Find your perfect dining companion")
                            .font(.roboto(14))
                            .foregroundColor(.uclaDarkBlue.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.uclaBlue)
                                    .frame(width: 25)
                                
                                TextField("UCLA Email", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.uclaBlue)
                                    .frame(width: 25)
                                
                                SecureField("Password", text: $password)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 30)
                        
                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 30)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            Task {
                                await authViewModel.login(email: email, password: password)
                            }
                        }) {
                            Text("Login")
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
                                .cornerRadius(15)
                                .shadow(color: .uclaBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 30)
                        
                        Button(action: {
                            showRegistration = true
                        }) {
                            HStack(spacing: 5) {
                                Text("Don't have an account?")
                                    .foregroundColor(.uclaDarkBlue.opacity(0.7))
                                Text("Register")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.uclaBlue)
                            }
                            .font(.subheadline)
                        }
                    }
                    
                    Spacer()
                    Spacer()
                }
            }
            .sheet(isPresented: $showRegistration) {
                RegistrationView()
                    .environmentObject(authViewModel)
            }
        }
        .accentColor(.uclaBlue)
    }
}
