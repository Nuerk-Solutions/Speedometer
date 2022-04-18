//
//  MotionService.swift
//  Speedometer
//
//  Created by Thomas on 10.04.22.
//

import Foundation
import CoreMotion
import CoreData
import SwiftUI


class MotionService: ObservableObject {
    
    let manager = CMMotionManager()
    @Published var motionDate: Date = Date()
    @Published var accelerationX: Double?
    @Published var accelerationY: Double?
    @Published var accelerationZ: Double?
    
    @Published var rotationRateX: Double?
    @Published var rotationRateY: Double?
    @Published var rotationRateZ: Double?
    
    @Published var magneticFieldAccuracy: Int32?
    @Published var magneticFieldX: Double?
    @Published var magneticFieldY: Double?
    @Published var magneticFieldZ: Double?
    
    @Published var gravityX: Double?
    @Published var gravityY: Double?
    @Published var gravityZ: Double?
    
    @Published var heading: Double?
    
    
    var viewContext: NSManagedObjectContext?
    
    init() {
        manager.deviceMotionUpdateInterval = 0.05
        manager.magnetometerUpdateInterval = 0.05
        manager.gyroUpdateInterval = 0.05
        manager.accelerometerUpdateInterval = 0.05
        manager.showsDeviceMovementDisplay = true
    }
    
    
    func setViewContext(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func startMotionUpdates() {
        manager.startMagnetometerUpdates()
        manager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical, to: .main) { (motion, error) in
            
            self.motionDate = String.timestamp().tad2Date()!
            self.heading = motion?.heading
            
            // Get accelerometer sensor data
            self.accelerationX = motion?.userAcceleration.x
            self.accelerationY = motion?.userAcceleration.y
            self.accelerationZ = motion?.userAcceleration.z

            // Get gyroscope sensor data
            self.rotationRateX =  motion?.rotationRate.x
            self.rotationRateY = motion?.rotationRate.y
            self.rotationRateZ = motion?.rotationRate.z

            // Get magnetometer sensor data
            self.magneticFieldAccuracy =  motion?.magneticField.accuracy.rawValue
            self.magneticFieldX = motion?.magneticField.field.x
            self.magneticFieldY = motion?.magneticField.field.y
            self.magneticFieldZ = motion?.magneticField.field.z
            
            self.gravityX = motion?.gravity.x
            self.gravityY = motion?.gravity.y
            self.gravityZ = motion?.gravity.z
            
            withAnimation {
                let newItem = Item(context: self.viewContext!)
                newItem.timestamp = String.timestamp().tad2Date()
                newItem.timestampMotion = String.timestamp().tad2Date()
                newItem.accelerationX = self.accelerationX ?? -1
                newItem.accelerationY = self.accelerationY ?? -1
                newItem.accelerationZ = self.accelerationZ ?? -1
                newItem.magneticFieldX = self.magneticFieldX ?? -1
                newItem.magneticFieldY = self.magneticFieldY ?? -1
                newItem.magneticFieldZ = self.magneticFieldZ ?? -1
                newItem.magneticFieldAccuracy = Int32(self.magneticFieldAccuracy ?? -1)
                newItem.rotationRateX = self.rotationRateX ?? -1
                newItem.rotationRateY = self.rotationRateY ?? -1
                newItem.rotationRateZ = self.rotationRateZ ?? -1
                newItem.gravityX = self.gravityX ?? -1
                newItem.gravityY = self.gravityY ?? -1
                newItem.gravityZ = self.gravityZ ?? -1
                
                do {
                    try self.viewContext!.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.localizedDescription)")
                }
            }
        }
    }
    
    func stopMotionUpdates() {
        manager.stopDeviceMotionUpdates()
        manager.stopMagnetometerUpdates()
    }
}
