//
//  Untitled.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//
import Foundation
import FirebaseFirestore

struct Conversation: Codable, Identifiable {
    @DocumentID var id: String?
    let participants: [String]
    let participantNames: [String: String]
    let postId: String
    let restaurantName: String
    var lastMessage: String?
    var lastMessageTime: Date?
    var lastMessageSenderId: String?
    var hasUnreadMessages: Bool?
    let createdAt: Date
}
