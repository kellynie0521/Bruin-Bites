//
//  DiningRequest.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import FirebaseFirestore

enum RequestStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}

struct DiningRequest: Identifiable, Codable {
    @DocumentID var id: String?
    var fromUserId: String
    var fromUsername: String
    var toUserId: String
    var toUsername: String
    var postId: String
    var restaurantName: String
    var timeSlot: String
    var message: String?
    var status: String
    var conversationId: String?
    var createdAt: Date
    var respondedAt: Date?
    
    var requestStatus: RequestStatus {
        RequestStatus(rawValue: status) ?? .pending
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromUserId
        case fromUsername
        case toUserId
        case toUsername
        case postId
        case restaurantName
        case timeSlot
        case message
        case status
        case conversationId
        case createdAt
        case respondedAt
    }
}
