//
//  ContentView.swift
//  Speedometer
//
//  Created by Thomas on 10.04.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject private var locationService: LocationService = LocationService()
    
    @ObservedObject private var motionService: MotionService = MotionService()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var isShareSheetShowing = false
    @State private var isRecording = false
    @State private var isExporting = false
    
    var body: some View {
        NavigationView {
            Form {
                //                Form {
                Section {
                    KeyValueRow(key: "Speed", value: locationService.speed?.toString())
                    KeyValueRow(key: "Speed accuracy", value: locationService.speedAccuracy?.toString())
                } header: {
                    Text("Speed")
                        .font(.headline)
                } footer: {
                    Text("The instantaneous speed of the device, measured in meters per second.")
                }
                Section {
                    KeyValueRow(key: "Course", value: locationService.course?.toString())
                    KeyValueRow(key: "Course accuracy", value: locationService.courseAccuracy?.toString())
                    KeyValueRow(key: "Floor", value: locationService.floor?.toString())
                } header: {
                    Text("Navigation")
                        .font(.headline)
                } footer: {
                    Text("The direction in which the device is traveling, measured in degrees and relative to due north.\n The floor value represent the logical floor of the building in which the user is located.")
                }
                
                Section {
                    KeyValueRow(key: "Heading accuracy", value: locationService.headingAccuracy?.toString())
                    KeyValueRow(key: "X", value: locationService.headingX?.toString())
                    KeyValueRow(key: "Y", value: locationService.headingY?.toString())
                    KeyValueRow(key: "Z", value: locationService.headingZ?.toString())
                    
                    KeyValueRow(key: "Orientation", value: locationService.headingOrientation?.toString())
                    KeyValueRow(key: "Magnetic heading", value: locationService.magneticHeading?.toString())
                    KeyValueRow(key: "Timestamp", value: locationService.headingTimestamp?.Date2Tad())
                    KeyValueRow(key: "True heading", value: locationService.trueHeading?.toString())
                    KeyValueRow(key: "Motion heading", value: motionService.heading?.toString())
                        .listRowBackground(Color.gray.opacity(0.2))
                } header: {
                    Text("Heading")
                        .font(.headline)
                }
                
                Section {
                    KeyValueRow(key: "Altitude", value: locationService.altitude?.toString())
                    KeyValueRow(key: "Ellipsoidal altitude", value: locationService.ellipsoidalAltitude?.toString())
                    KeyValueRow(key: "Latitude", value: locationService.latitude?.toString())
                    KeyValueRow(key: "Longitude", value: locationService.longitude?.toString())
                    KeyValueRow(key: "Vertical accuracy", value: locationService.verticalAccuracy?.toString())
                    KeyValueRow(key: "Horizontal accuracy", value: locationService.horizontalAccuracy?.toString())
                } header: {
                    Text("Coordinate")
                        .font(.headline)
                } footer: {
                    Text("Contains the geographical location and altitude of a device, along with values indicating the accuracy of those measurements.")
                }
                
                Section {
                    KeyValueRow(key: "Timestamp", value: motionService.motionDate.Date2Tad())
                    KeyValueRow(key: "X", value: motionService.accelerationX?.toString())
                    KeyValueRow(key: "Y", value: motionService.accelerationY?.toString())
                    KeyValueRow(key: "Z", value: motionService.accelerationZ?.toString())
                } header: {
                    Text("Acceleration")
                        .font(.headline)
                } footer: {
                    Text("The total acceleration of the device is equal to gravity plus the acceleration the user imparts to the device.")
                }
                
                
                Section {
                    KeyValueRow(key: "X", value: motionService.gravityX?.toString())
                    KeyValueRow(key: "Y", value: motionService.gravityY?.toString())
                    KeyValueRow(key: "Z", value: motionService.gravityZ?.toString())
                } header: {
                    Text("Gravity")
                        .font(.headline)
                } footer: {
                    Text("The gravity acceleration vector expressed in the device's reference frame.")
                }
                
                
                Section {
                    KeyValueRow(key: "X", value: motionService.rotationRateX?.toString())
                    KeyValueRow(key: "Y", value: motionService.rotationRateY?.toString())
                    KeyValueRow(key: "Z", value: motionService.rotationRateZ?.toString())
                } header: {
                    Text("Rotation rate")
                        .font(.headline)
                } footer: {
                    Text("The rotation rate contains data specifying the device’s rate of rotation around three axes. The value of this property contains a measurement of raw gyroscope data whose bias has been removed by algorithms.")
                }
                Section {
                    KeyValueRow(key: "Field accuracy", value: motionService.magneticFieldAccuracy?.toString())
                    KeyValueRow(key: "X", value: motionService.magneticFieldX?.toString())
                    KeyValueRow(key: "Y", value: motionService.magneticFieldY?.toString())
                    KeyValueRow(key: "Z", value: motionService.magneticFieldZ?.toString())
                } header: {
                    Text("Magnetic field")
                        .font(.headline)
                }
            }
            .navigationBarTitle("Speedometer")
            .toolbar {
                ToolbarItem {
                    Button {
                        if !isRecording {
                            items.forEach(viewContext.delete(_:))
                            
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                            isRecording.toggle()
                            locationService.locationManager.startUpdatingLocation()
                            locationService.locationManager.startUpdatingHeading()
                            locationService.locationManager.startMonitoringVisits()
                            motionService.startMotionUpdates()
                            return
                        }
                        isRecording.toggle()
                        locationService.locationManager.stopUpdatingLocation()
                        locationService.locationManager.stopUpdatingHeading()
                        locationService.locationManager.stopMonitoringVisits()
                        motionService.stopMotionUpdates()
                    } label: {
                        Label("Start_Stop", systemImage: isRecording ? "stop.circle" : "play.circle")
                            .font(.title)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: shareButton)
                    {
                        Label("Export CSV", systemImage: "square.and.arrow.up")
                            .font(.title)
                        
                    }
                }
            }
            .overlay(content: {
                if isExporting {
                    ProgressView()
                }
            })
        }
        .onAppear {
            locationService.locationManager.requestWhenInUseAuthorization()
            locationService.setViewContext(viewContext: viewContext)
            motionService.setViewContext(viewContext: viewContext)
        }
    }
    
    func shareButton() {
        withAnimation {
            isExporting.toggle()
        }
        
        defer {
            isExporting.toggle()
        }
        
        let fileName = "MotionData_\(Date().ISO8601Format(.iso8601)).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "timestamp,locationTimestamp,speed,speedAccuracy,ellipsodialAltidue,altitude,latitude,longitude,verticalAccuracy,horizontalAccuracy,course,courseAccuracy,floor, ,motionTimestamp,accelerationX,accelerationY,accelerationZ,rotationRateX,rotationRateY,rotationRateZ,magneticFieldAccuracy,magneticFieldX,magneticFieldY,magneticFieldZ,gravityX,gravityY,gravityZ\n"
        
        for item in items {
            let timeStampString = item.timestamp?.Date2Tad()
            let timestampLocationString = item.timestampLocation?.Date2Tad()
            let timestampMotionString = item.timestampMotion?.Date2Tad()
            
            csvText += "\(timeStampString ?? "No Date!"),\(timestampLocationString ?? "No Date!"),\(item.speed),\(item.speedAccuracy),\(item.ellipsoidalAltitude),\(item.altitude),\(item.latitude),\(item.longitude),\(item.verticalAccuracy),\(item.horizontalAccuracy),\(item.course),\(item.courseAccuracy),\(item.floor), ,\(timestampMotionString ?? "No Date!"),\(item.accelerationX),\(item.accelerationY),\(item.accelerationZ),\(item.rotationRateX),\(item.rotationRateY),\(item.rotationRateZ),\(item.magneticFieldAccuracy),\(item.magneticFieldX),\(item.magneticFieldY),\(item.magneticFieldZ),\(item.gravityX),\(item.gravityY),\(item.gravityZ)\n"
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        print(path ?? "not found")
        
        var filesToShare = [Any]()
        filesToShare.append(path!)
        
        let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        
        UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .present(av, animated: true)
        
        isShareSheetShowing.toggle()
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(LocationService())
            .environmentObject(MotionService())
    }
}


extension Int {
    func toString() -> String {
        return String(self)
    }
}

extension Int32 {
    func toString() -> String {
        return String(self)
    }
}


extension Double {
    func toString() -> String {
        return String(self)
    }
}
