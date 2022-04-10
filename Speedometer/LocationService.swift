//
//  LocationService.swift
//  Speedometer
//
//  Created by Thomas on 10.04.22.
//

import Foundation
import CoreLocation
import SwiftUI

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager
    
    @Published var authorizationStatus: CLAuthorizationStatus // For always in background question
    @Published var lastSeenLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    @Published var currentSpeed: String = ""
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 0.1
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
        let mPerS = locationManager.location?.speed
        let kmPerH = (mPerS ?? 0) * 3.6
        currentSpeed = "m/s: \(mPerS ?? 0.0) | km/h:  \(kmPerH)"
        print("m/s: \(mPerS ?? 0.0) | km/h:  \(kmPerH)")
    }
    
    // TODO: Check wich method works
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
        print(status)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        print(manager.authorizationStatus)
    }
    
//    func requestLocationPermission() {
//        self.locationManager.requestAlwaysAuthorization()
//    }
    
    
    func hasPermission() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied :
                return false
                
            case .authorizedWhenInUse, .authorizedAlways:
                return true
                
            default:
                return false
            }
        }
        return false
    }
}
