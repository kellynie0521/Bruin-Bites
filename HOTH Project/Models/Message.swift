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
