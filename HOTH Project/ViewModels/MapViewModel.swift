//
//  MapViewModel.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import Foundation
import MapKit
import FirebaseFirestore
import CoreLocation

@MainActor
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var posts: [DiningPost] = []
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        fetchPosts()
    }
    
    func fetchPosts() {
        db.collection("diningPosts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.posts = documents.compactMap { document in
                    try? document.data(as: DiningPost.self)
                }
            }
    }
    
    func createPost(
        userId: String,
        username: String,
        grade: String,
        gender: String,
        restaurantName: String,
        address: String,
        timeSlot: String,
        notes: String,
        completion: @escaping (Bool) -> Void
    ) {
        geocodeAddress(address) { coordinate in
            guard let coordinate = coordinate else {
                self.errorMessage = "Could not find location"
                completion(false)
                return
            }
            
            self.searchRestaurantWebsite(restaurantName: restaurantName, coordinate: coordinate) { website in
                let post = DiningPost(
                    userId: userId,
                    username: username,
                    grade: grade,
                    gender: gender,
                    restaurantName: restaurantName,
                    address: address,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    timeSlot: timeSlot,
                    notes: notes,
                    restaurantWebsite: website,
                    createdAt: Date()
                )
                
                do {
                    _ = try self.db.collection("diningPosts").addDocument(from: post)
                    completion(true)
                } catch {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    private func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                completion(coordinate)
            } else {
                completion(nil)
            }
        }
    }
    
    private func searchRestaurantWebsite(restaurantName: String, coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = restaurantName
        request.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let mapItem = response?.mapItems.first {
                completion(mapItem.url?.absoluteString)
            } else {
                completion(nil)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}
