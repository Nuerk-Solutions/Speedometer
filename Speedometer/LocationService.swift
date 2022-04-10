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
    
    @Published var currentSpeed: Double?
    @Published var speedAccury: Double?
    
    @Published var timestamp: Date?
    
    @Published var altitude: Double?
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var ellipsoidalAltitude:Double?
    
    @Published var course: Double?
    @Published var courseAccuracy:Double?
    
    @Published var floor: Int?
    
    @Published var verticalAccuracy:Double?
    @Published var horizontalAccuracy:Double?
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 0
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentSpeed = locationManager.location?.speed
        speedAccury = locationManager.location?.speedAccuracy
        timestamp = locationManager.location?.timestamp
        altitude = locationManager.location?.altitude
        latitude = locationManager.location?.coordinate.latitude
        longitude = locationManager.location?.coordinate.longitude
        course = locationManager.location?.course
        courseAccuracy = locationManager.location?.courseAccuracy
        floor = locationManager.location?.floor?.level
        verticalAccuracy = locationManager.location?.verticalAccuracy
        horizontalAccuracy = locationManager.location?.horizontalAccuracy
        ellipsoidalAltitude = locationManager.location?.ellipsoidalAltitude
    }
    
    // TODO: Check wich method works
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
    }
}
