//
//  MotionService.swift
//  Speedometer
//
//  Created by Thomas on 10.04.22.
//

import Foundation
import CoreMotion


class MotionService: ObservableObject {
    
    let manager = CMMotionManager()
    @Published var motionDate: Date?
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
    
    init() {
        manager.deviceMotionUpdateInterval = 0.1
    }
    
    func startMotionUpdates() {
        manager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            self.motionDate = Date()
            
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
        }
    }
    
    func stopMotionUpdates() {
        manager.stopDeviceMotionUpdates()
    }
}
