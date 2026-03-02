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
internal import Combine

@MainActor
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var posts: [DiningPost] = []
    @Published var errorMessage = ""
    @Published var userLocation: CLLocation?
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let db = Firestore.firestore()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 获取当前授权状态
        if #available(iOS 14.0, *) {
            locationAuthorizationStatus = locationManager.authorizationStatus
        } else {
            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        print("🔵 MapViewModel initialized, current location status: \(locationAuthorizationStatus.rawValue)")
        
        fetchPosts()
        
        // 如果已经授权，立即开始更新位置
        if locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways {
            print("✅ Already authorized, starting location updates")
            locationManager.startUpdatingLocation()
        }
    }
    
    func requestLocationPermission() {
        print("🔵 Requesting location permission, current status: \(locationAuthorizationStatus.rawValue)")
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        if locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func fetchPosts() {
        db.collection("diningPosts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents in snapshot")
                    return
                }
                
                print("📊 Fetched \(documents.count) dining posts from Firestore")
                
                self.posts = documents.compactMap { document in
                    do {
                        let post = try document.data(as: DiningPost.self)
                        print("  ✅ Post: \(post.restaurantName) at (\(post.latitude), \(post.longitude))")
                        return post
                    } catch {
                        print("  ❌ Failed to decode post: \(error)")
                        return nil
                    }
                }
                
                print("✅ Total posts loaded: \(self.posts.count)")
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
        category: String?,
        transportation: String?,
        completion: @escaping (Bool) -> Void
    ) {
        geocodeAddress(address) { coordinate in
            guard let coordinate = coordinate else {
                self.errorMessage = "Could not find location"
                completion(false)
                return
            }
            
            self.createPostWithCoordinate(
                userId: userId,
                username: username,
                grade: grade,
                gender: gender,
                restaurantName: restaurantName,
                address: address,
                coordinate: coordinate,
                timeSlot: timeSlot,
                notes: notes,
                category: category,
                transportation: transportation,
                completion: completion
            )
        }
    }
    
    func createPostWithCoordinate(
        userId: String,
        username: String,
        grade: String,
        gender: String,
        restaurantName: String,
        address: String,
        coordinate: CLLocationCoordinate2D,
        timeSlot: String,
        notes: String,
        category: String?,
        transportation: String?,
        completion: @escaping (Bool) -> Void
    ) {
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
                category: category,
                transportation: transportation,
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
            Task { @MainActor in
                userLocation = location
                print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                print("   Accuracy: \(location.horizontalAccuracy) meters")
                print("   Current posts count: \(posts.count)")
                
                // 打印每个餐厅的距离
                for post in posts {
                    if let distance = post.distance(from: userLocation) {
                        print("   → \(post.restaurantName): \(distance)")
                    }
                }
                
                // 只在第一次获取位置时更新地图中心
                if region.center.latitude == 34.0689 && region.center.longitude == -118.4452 {
                    print("   ✅ Centering map on user location")
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            print("🔵 Location authorization changed to: \(status.rawValue)")
            locationAuthorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                print("✅ Location authorized, starting updates...")
                locationManager.startUpdatingLocation()
                print("   Location updates started, waiting for location...")
            } else if status == .denied {
                print("❌ Location access denied")
            } else if status == .notDetermined {
                print("⚠️ Location status: not determined")
            }
        }
    }
}
