//
//  LocationService.swift
//  Speedometer
//
//  Created by Thomas on 10.04.22.
//

import Foundation
import CoreLocation
import SwiftUI
import CoreData

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager
    @Published var authorizationStatus: CLAuthorizationStatus // For always in background question
    
    @Published var speed: Double?
    @Published var speedAccuracy: Double?
    
    @Published var timestampLocation: Date?
    
    @Published var altitude: Double?
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var ellipsoidalAltitude:Double?
    
    @Published var course: Double?
    @Published var courseAccuracy:Double?
    
    @Published var floor: Int?
    
    @Published var verticalAccuracy:Double?
    @Published var horizontalAccuracy:Double?
    
    var viewContext: NSManagedObjectContext?
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 0
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func setViewContext(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        speed = locationManager.location?.speed
        speedAccuracy = locationManager.location?.speedAccuracy
        timestampLocation = locationManager.location?.timestamp
        altitude = locationManager.location?.altitude
        latitude = locationManager.location?.coordinate.latitude
        longitude = locationManager.location?.coordinate.longitude
        course = locationManager.location?.course
        courseAccuracy = locationManager.location?.courseAccuracy
        floor = locationManager.location?.floor?.level
        verticalAccuracy = locationManager.location?.verticalAccuracy
        horizontalAccuracy = locationManager.location?.horizontalAccuracy
        ellipsoidalAltitude = locationManager.location?.ellipsoidalAltitude
        
        
        withAnimation {
            let newItem = Item(context: viewContext!)
            newItem.timestamp = Date()
            newItem.timestampLocation = locationManager.location?.timestamp
            newItem.speed = speed ?? -1
            newItem.speedAccuracy = speedAccuracy ?? -1
            newItem.altitude = altitude ?? -1
            newItem.latitude = latitude ?? -1
            newItem.longitude = longitude ?? -1
            newItem.course = course ?? -1
            newItem.courseAccuracy = courseAccuracy ?? -1
            newItem.floor = Int32(floor ?? -1)
            newItem.verticalAccuracy = verticalAccuracy ?? -1
            newItem.horizontalAccuracy = horizontalAccuracy ?? -1
            newItem.ellipsoidalAltitude = ellipsoidalAltitude ?? -1
            
            do {
                try viewContext!.save()
            } catch {
                print("===========")
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.localizedDescription)")
            }
        }
    }
    
    // TODO: Check wich method works
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
    }
}
