//
//  RequestViewModel.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import FirebaseFirestore
internal import Combine

@MainActor
class RequestViewModel: ObservableObject {
    @Published var sentRequests: [DiningRequest] = []
    @Published var receivedRequests: [DiningRequest] = []
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    func sendDiningRequest(
        fromUserId: String,
        fromUsername: String,
        toUserId: String,
        toUsername: String,
        postId: String,
        restaurantName: String,
        timeSlot: String,
        message: String?,
        completion: @escaping (Bool) -> Void
    ) {
        print("🔵 Sending dining request from \(fromUsername) to \(toUsername)")
        print("   From: \(fromUserId)")
        print("   To: \(toUserId)")
        print("   Post: \(postId)")
        print("   Restaurant: \(restaurantName)")
        
        let request = DiningRequest(
            fromUserId: fromUserId,
            fromUsername: fromUsername,
            toUserId: toUserId,
            toUsername: toUsername,
            postId: postId,
            restaurantName: restaurantName,
            timeSlot: timeSlot,
            message: message,
            status: RequestStatus.pending.rawValue,
            conversationId: nil,
            createdAt: Date(),
            respondedAt: nil
        )
        
        Task {
            do {
                let docRef = try db.collection("diningRequests").addDocument(from: request)
                print("✅ Request sent successfully with ID: \(docRef.documentID)")
                
                await MainActor.run {
                    completion(true)
                }
            } catch {
                print("❌ Error sending request: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    func fetchSentRequests(userId: String) {
        print("🔵 Fetching sent requests for user: \(userId)")
        
        db.collection("diningRequests")
            .whereField("fromUserId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching sent requests: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found")
                    return
                }
                
                print("✅ Found \(documents.count) sent requests")
                
                self.sentRequests = documents.compactMap { document in
                    do {
                        let request = try document.data(as: DiningRequest.self)
                        print("  - Request to \(request.toUsername): \(request.status)")
                        return request
                    } catch {
                        print("❌ Error decoding request: \(error)")
                        return nil
                    }
                }
            }
    }
    
    func fetchReceivedRequests(userId: String) {
        print("🔵 Fetching received requests for user: \(userId)")
        
        db.collection("diningRequests")
            .whereField("toUserId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching received requests: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found")
                    return
                }
                
                print("✅ Found \(documents.count) received requests")
                
                self.receivedRequests = documents.compactMap { document in
                    do {
                        let request = try document.data(as: DiningRequest.self)
                        print("  - Request from \(request.fromUsername): \(request.status)")
                        return request
                    } catch {
                        print("❌ Error decoding request: \(error)")
                        return nil
                    }
                }
            }
    }
    
    func respondToRequest(
        requestId: String,
        accept: Bool,
        chatViewModel: ChatViewModel,
        completion: @escaping (String?) -> Void
    ) {
        print("🔵 respondToRequest called - requestId: \(requestId), accept: \(accept)")
        
        guard let request = receivedRequests.first(where: { $0.id == requestId }) else {
            print("❌ Request not found in receivedRequests")
            completion(nil)
            return
        }
        
        print("✅ Found request from \(request.fromUsername)")
        
        if accept {
            print("🔵 Creating conversation...")
            chatViewModel.createOrGetConversation(
                currentUserId: request.toUserId,
                currentUsername: request.toUsername,
                postOwnerId: request.fromUserId,
                postOwnerUsername: request.fromUsername,
                postId: request.postId,
                restaurantName: request.restaurantName
            ) { conversationId in
                print("🔵 Conversation creation callback - conversationId: \(String(describing: conversationId))")
                if let conversationId = conversationId {
                    print("🔵 Updating request status to accepted...")
                    self.db.collection("diningRequests").document(requestId).updateData([
                        "status": RequestStatus.accepted.rawValue,
                        "conversationId": conversationId,
                        "respondedAt": Date()
                    ]) { error in
                        if let error = error {
                            print("❌ Error updating request: \(error.localizedDescription)")
                            self.errorMessage = error.localizedDescription
                            completion(nil)
                        } else {
                            print("✅ Request accepted successfully")
                            completion(conversationId)
                        }
                    }
                } else {
                    print("❌ Failed to create conversation")
                    completion(nil)
                }
            }
        } else {
            print("🔵 Declining request...")
            db.collection("diningRequests").document(requestId).updateData([
                "status": RequestStatus.rejected.rawValue,
                "respondedAt": Date()
            ]) { error in
                if let error = error {
                    print("❌ Error declining request: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                } else {
                    print("✅ Request declined successfully")
                }
                completion(nil)
            }
        }
    }
}
