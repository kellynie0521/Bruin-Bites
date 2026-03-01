//
//  ChatViewModel.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import FirebaseFirestore


@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var conversations: [Conversation] = []
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?
    
    func fetchConversations(userId: String) {
        db.collection("conversations")
            .whereField("participants", arrayContains: userId)
            .order(by: "lastMessageTime", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.conversations = documents.compactMap { document in
                    try? document.data(as: Conversation.self)
                }
            }
    }
    
    func createOrGetConversation(
        currentUserId: String,
        currentUsername: String,
        postOwnerId: String,
        postOwnerUsername: String,
        postId: String,
        restaurantName: String,
        completion: @escaping (String?) -> Void
    ) {
        let participants = [currentUserId, postOwnerId].sorted()
        
        db.collection("conversations")
            .whereField("participants", isEqualTo: participants)
            .whereField("postId", isEqualTo: postId)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(nil)
                    return
                }
                
                if let existingConversation = snapshot?.documents.first {
                    completion(existingConversation.documentID)
                } else {
                    let conversation = Conversation(
                        participants: participants,
                        participantNames: [
                            currentUserId: currentUsername,
                            postOwnerId: postOwnerUsername
                        ],
                        postId: postId,
                        restaurantName: restaurantName,
                        lastMessage: nil,
                        lastMessageTime: nil,
                        createdAt: Date()
                    )
                    
                    do {
                        let docRef = try self.db.collection("conversations").addDocument(from: conversation)
                        completion(docRef.documentID)
                    } catch {
                        self.errorMessage = error.localizedDescription
                        completion(nil)
                    }
                }
            }
    }
    
    func fetchMessages(conversationId: String) {
        messagesListener?.remove()
        
        messagesListener = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.messages = documents.compactMap { document in
                    try? document.data(as: Message.self)
                }
            }
    }
    
    func sendMessage(conversationId: String, senderId: String, senderName: String, text: String) {
        let message = Message(
            senderId: senderId,
            senderName: senderName,
            text: text,
            timestamp: Date()
        )
        
        do {
            _ = try db.collection("conversations")
                .document(conversationId)
                .collection("messages")
                .addDocument(from: message)
            
            db.collection("conversations")
                .document(conversationId)
                .updateData([
                    "lastMessage": text,
                    "lastMessageTime": Date()
                ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    deinit {
        messagesListener?.remove()
    }
}
