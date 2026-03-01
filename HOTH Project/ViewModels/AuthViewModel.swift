//
//  AuthViewModel.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    init() {
        checkAuth()
    }
    
    func checkAuth() {
        if let firebaseUser = Auth.auth().currentUser {
            fetchUser(userId: firebaseUser.uid)
        }
    }
    
    func register(email: String, password: String, username: String, grade: String, gender: String) async {
        guard email.lowercased().hasSuffix("@ucla.edu") else {
            errorMessage = "Please use a valid UCLA email address"
            return
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            let newUser = User(
                id: result.user.uid,
                email: email,
                username: username,
                grade: grade,
                gender: gender,
                createdAt: Date()
            )
            
            try db.collection("users").document(result.user.uid).setData(from: newUser)
            
            try await result.user.sendEmailVerification()
            
            self.user = newUser
            self.isAuthenticated = true
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func login(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            fetchUser(userId: result.user.uid)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            user = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func fetchUser(userId: String) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                do {
                    self.user = try snapshot.data(as: User.self)
                    self.isAuthenticated = true
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
