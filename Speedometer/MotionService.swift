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
    @Published var motionData: String = ""
    
    @Published var accelerationX: String?
    @Published var accelerationY: String?
    @Published var accelerationZ: String?
    
    @Published var rotationRateX: String?
    @Published var rotationRateY: String?
    @Published var rotationRateZ: String?
    
    @Published var magneticFieldAccuracy: String?
    @Published var magneticFieldX: String?
    @Published var magneticFieldY: String?
    @Published var magneticFieldZ: String?
    
    init() {
        manager.deviceMotionUpdateInterval = 0.1
        manager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            self.motionData = "\(String(describing: motion?.userAcceleration))"
        }
    }
}
