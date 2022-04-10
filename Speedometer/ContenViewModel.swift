//
//  ContenViewModel.swift
//  Speedometer
//
//  Created by Thomas on 10.04.22.
//

import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {
    
    @Published var isRecording = false
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var motionService: MotionService
    
    
    func start() {
    }
    
    func stop() {
        
    }
}
