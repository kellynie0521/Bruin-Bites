//
//  Message.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var senderName: String
    var text: String
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case senderName
        case text
        case timestamp
    }
}

struct Conversation: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var participantNames: [String: String]
    var postId: String
    var restaurantName: String
    var lastMessage: String?
    var lastMessageTime: Date?
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case participants
        case participantNames
        case postId
        case restaurantName
        case lastMessage
        case lastMessageTime
        case createdAt
    }
}
