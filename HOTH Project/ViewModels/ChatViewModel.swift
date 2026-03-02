//
//  ChatViewModel.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import FirebaseFirestore
internal import Combine

@MainActor
class ChatViewModel: ObservableObject {
    var objectWillChange = ObservableObjectPublisher ()
    
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
        print("🔵 createOrGetConversation called")
        print("   Current user: \(currentUsername) (\(currentUserId))")
        print("   Post owner: \(postOwnerUsername) (\(postOwnerId))")
        print("   Post ID: \(postId)")
        
        let participants = [currentUserId, postOwnerId].sorted()
        
        print("🔵 Searching for existing conversation...")
        db.collection("conversations")
            .whereField("participants", isEqualTo: participants)
            .whereField("postId", isEqualTo: postId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error searching for conversation: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    completion(nil)
                    return
                }
                
                if let existingConversation = snapshot?.documents.first {
                    print("✅ Found existing conversation: \(existingConversation.documentID)")
                    completion(existingConversation.documentID)
                } else {
                    print("🔵 No existing conversation found, creating new one...")
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
                        lastMessageSenderId: nil,
                        hasUnreadMessages: nil,
                        createdAt: Date()
                    )
                    
                    do {
                        let docRef = try self.db.collection("conversations").addDocument(from: conversation)
                        print("✅ Created new conversation: \(docRef.documentID)")
                        completion(docRef.documentID)
                    } catch {
                        print("❌ Error creating conversation: \(error.localizedDescription)")
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
            
            // 更新对话的最后消息和未读状态
            db.collection("conversations")
                .document(conversationId)
                .updateData([
                    "lastMessage": text,
                    "lastMessageTime": Date(),
                    "lastMessageSenderId": senderId,
                    "hasUnreadMessages": true  // 标记为有未读消息
                ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // 标记对话为已读
    func markConversationAsRead(conversationId: String) {
        db.collection("conversations")
            .document(conversationId)
            .updateData([
                "hasUnreadMessages": false
            ])
    }
    
    deinit {
        messagesListener?.remove()
    }
}
