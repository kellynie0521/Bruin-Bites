//
//  AuthViewModel.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit
internal import Combine

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
            Task {
                await fetchUser(userId: firebaseUser.uid)
            }
        }
    }
    
    func register(email: String, password: String, username: String, grade: String, gender: String) async {
        print("🔵 Register called with email: \(email)")
        
        guard email.lowercased().hasSuffix("@ucla.edu") else {
            errorMessage = "Please use a valid UCLA email address"
            print("❌ Invalid email domain")
            return
        }
        
        do {
            print("🔵 Creating user...")
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("✅ User created: \(result.user.uid)")
            
            let newUser = User(
                id: result.user.uid,
                email: email,
                username: username,
                grade: grade,
                gender: gender,
                createdAt: Date()
            )
            
            print("🔵 Saving user to Firestore...")
            try db.collection("users").document(result.user.uid).setData(from: newUser)
            print("✅ User saved to Firestore")
            
            print("🔵 Sending verification email...")
            try await result.user.sendEmailVerification()
            print("✅ Verification email sent")
            
            self.user = newUser
            self.isAuthenticated = true
            errorMessage = ""
            print("✅ Registration complete, isAuthenticated: \(self.isAuthenticated)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Registration error: \(error.localizedDescription)")
        }
    }
    
    func login(email: String, password: String) async {
        print("🔵 Login called with email: \(email)")
        
        do {
            print("🔵 Signing in...")
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ Sign in successful: \(result.user.uid)")
            
            await fetchUser(userId: result.user.uid)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Login error: \(error.localizedDescription)")
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
    
    private func fetchUser(userId: String) async {
        print("🔵 Fetching user data for: \(userId)")
        
        do {
            let snapshot = try await db.collection("users").document(userId).getDocument()
            
            if snapshot.exists {
                let fetchedUser = try snapshot.data(as: User.self)
                self.user = fetchedUser
                self.isAuthenticated = true
                
                print("✅ User fetched, isAuthenticated: \(self.isAuthenticated)")
                print("✅ User info: \(fetchedUser.username)")
            } else {
                self.errorMessage = "User data not found"
                print("❌ User document does not exist")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Fetch user error: \(error.localizedDescription)")
        }
    }
    
    // 上传头像到 Firebase Storage 并更新用户信息
    func uploadProfileImage(_ image: UIImage) async {
        guard let userId = user?.id else {
            print("❌ No user ID found")
            await MainActor.run {
                errorMessage = "No user logged in"
            }
            return
        }
        
        print("🔵 Starting profile image upload for user: \(userId)")
        print("🔵 Image size: \(image.size.width) x \(image.size.height)")
        
        // 压缩图片
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("❌ Failed to convert image to data")
            await MainActor.run {
                errorMessage = "Failed to process image"
            }
            return
        }
        
        print("🔵 Image data size: \(imageData.count) bytes")
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profile_images/\(userId).jpg")
        
        print("🔵 Storage path: profile_images/\(userId).jpg")
        
        do {
            // 上传图片
            print("🔵 Uploading image to Firebase Storage...")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = try await profileImageRef.putDataAsync(imageData, metadata: metadata)
            print("✅ Image uploaded successfully to Firebase Storage")
            
            // 获取下载 URL
            print("🔵 Getting download URL...")
            let downloadURL = try await profileImageRef.downloadURL()
            print("✅ Download URL obtained: \(downloadURL.absoluteString)")
            
            // 更新 Firestore 中的用户数据
            print("🔵 Updating user profile in Firestore...")
            try await db.collection("users").document(userId).updateData([
                "profileImageUrl": downloadURL.absoluteString
            ])
            print("✅ User profile updated in Firestore")
            
            // 更新本地用户对象
            await MainActor.run {
                if var updatedUser = self.user {
                    updatedUser.profileImageUrl = downloadURL.absoluteString
                    self.user = updatedUser
                    print("✅ Local user object updated")
                }
                errorMessage = ""
            }
        } catch let error as NSError {
            print("❌ Error uploading profile image:")
            print("   Error domain: \(error.domain)")
            print("   Error code: \(error.code)")
            print("   Error description: \(error.localizedDescription)")
            print("   Error userInfo: \(error.userInfo)")
            
            await MainActor.run {
                errorMessage = "Failed to upload image: \(error.localizedDescription)"
            }
        }
    }
}
