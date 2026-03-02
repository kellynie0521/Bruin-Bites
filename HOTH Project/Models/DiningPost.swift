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
    var category: String?
    var transportation: String?
    var createdAt: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func distance(from userLocation: CLLocation?) -> String? {
        guard let userLocation = userLocation else { return nil }
        let postLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = userLocation.distance(from: postLocation)
        let distanceInMiles = distanceInMeters / 1609.34
        
        if distanceInMiles < 0.1 {
            return "< 0.1 mi"
        } else if distanceInMiles < 1 {
            return String(format: "%.1f mi", distanceInMiles)
        } else {
            return String(format: "%.1f mi", distanceInMiles)
        }
    }
    
    var iconName: String {
        switch category?.lowercased() {
        case "cafe", "coffee":
            return "cup.and.saucer.fill"
        case "bakery":
            return "birthday.cake.fill"
        case "bar":
            return "wineglass.fill"
        case "fast food", "fastfood":
            return "takeoutbag.and.cup.and.straw.fill"
        default:
            return "fork.knife.circle.fill"
        }
    }
    
    var transportationIcon: String {
        switch transportation?.lowercased() {
        case "own car":
            return "car.fill"
        case "rideshare":
            return "car.circle.fill"
        case "public transit":
            return "bus.fill"
        case "walking":
            return "figure.walk"
        default:
            return "questionmark.circle"
        }
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
        case category
        case transportation
        case createdAt
    }
}

enum TimeSlot: String, CaseIterable {
    case breakfast = "Breakfast (7AM - 11AM)"
    case lunch = "Lunch (11AM - 3PM)"
    case dinner = "Dinner (5PM - 9PM)"
    case lateNight = "Late Night Snack (9PM - 2AM)"
}

enum Transportation: String, CaseIterable {
    case ownCar = "Own Car"
    case rideshare = "Rideshare (Uber/Lyft)"
    case publicTransit = "Public Transit"
    case walking = "Walking"
    case others = "Others"
    
    var icon: String {
        switch self {
        case .ownCar:
            return "car.fill"
        case .rideshare:
            return "car.circle.fill"
        case .publicTransit:
            return "bus.fill"
        case .walking:
            return "figure.walk"
        case .others:
            return "ellipsis.circle.fill"
        }
    }
}
