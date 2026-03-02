//
//  User.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var username: String
    var grade: String
    var gender: String
    var profileImageUrl: String?
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case grade
        case gender
        case profileImageUrl
        case createdAt
    }
}

enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-Binary"
    case preferNotToSay = "Prefer not to say"
}

enum Grade: String, CaseIterable {
    case freshman = "Freshman"
    case sophomore = "Sophomore"
    case junior = "Junior"
    case senior = "Senior"
    case graduate = "Graduate"
}
