//
//  DiningPost.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct DiningPost: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var username: String
    var grade: String
    var gender: String
    var restaurantName: String
    var address: String
    var latitude: Double
    var longitude: Double
    var timeSlot: String
    var notes: String
    var restaurantWebsite: String?
    var createdAt: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case username
        case grade
        case gender
        case restaurantName
        case address
        case latitude
        case longitude
        case timeSlot
        case notes
        case restaurantWebsite
        case createdAt
    }
}

enum TimeSlot: String, CaseIterable {
    case breakfast = "Breakfast (7AM - 11AM)"
    case lunch = "Lunch (11AM - 3PM)"
    case dinner = "Dinner (5PM - 9PM)"
}
