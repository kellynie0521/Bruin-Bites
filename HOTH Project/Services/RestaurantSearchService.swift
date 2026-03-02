//
//  RestaurantSearchService.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import MapKit
import CoreLocation
internal import Combine

struct RestaurantResult: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let mapItem: MKMapItem
    let category: String?
}

@MainActor
class RestaurantSearchService: ObservableObject {
    @Published var searchResults: [RestaurantResult] = []
    @Published var isSearching = false
    
    private var searchTask: Task<Void, Never>?
    
    func searchRestaurants(query: String, near coordinate: CLLocationCoordinate2D) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            isSearching = true
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            request.resultTypes = [.pointOfInterest]
            
            let search = MKLocalSearch(request: request)
            
            do {
                let response = try await search.start()
                
                if !Task.isCancelled {
                    searchResults = response.mapItems
                        .filter { mapItem in
                            guard let category = mapItem.pointOfInterestCategory else { return false }
                            return category == .restaurant || 
                                   category == .cafe || 
                                   category == .bakery ||
                                   category == .foodMarket ||
                                   category == .brewery ||
                                   category == .winery
                        }
                        .prefix(10)
                        .map { mapItem in
                            RestaurantResult(
                                name: mapItem.name ?? "",
                                address: formatAddress(from: mapItem.placemark),
                                coordinate: mapItem.placemark.coordinate,
                                mapItem: mapItem,
                                category: getCategoryName(from: mapItem.pointOfInterestCategory)
                            )
                        }
                }
            } catch {
                if !Task.isCancelled {
                    searchResults = []
                }
            }
            
            isSearching = false
        }
    }
    
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let subThoroughfare = placemark.subThoroughfare {
            addressComponents.append(subThoroughfare)
        }
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        return addressComponents.joined(separator: ", ")
    }
    
    private func getCategoryName(from category: MKPointOfInterestCategory?) -> String? {
        guard let category = category else { return nil }
        
        switch category {
        case .cafe:
            return "cafe"
        case .bakery:
            return "bakery"
        case .brewery, .winery:
            return "bar"
        case .foodMarket:
            return "fast food"
        default:
            return "restaurant"
        }
    }
}
