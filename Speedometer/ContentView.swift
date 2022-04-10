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
    
    //    @FetchRequest(entity: Item.entity(), sortDescriptors: []) var transactions: FetchedResults<Item>
    
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
            if !isRecording {
                VStack {
                    Button {
                        items.forEach(viewContext.delete(_:))
                        
                        do {
                            try viewContext.save()
                        } catch {
                            // Replace this implementation with code to handle the error appropriately.
                            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                        
                        withAnimation {
                            isRecording.toggle()
                        }
                        locationService.locationManager.startUpdatingLocation()
                        motionService.startMotionUpdates()
                    } label: {
                        Text("Aufzeichnung starten")
                            .padding(30)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                            .shadow(radius: 20)
                    }
                }
                .overlay {
                    if isExporting {
                        ProgressView()
                    }
                }
                .navigationBarTitle("Speedometer")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: shareButton)
                        {
                            Label("Export CSV", systemImage: "square.and.arrow.up")
                                .font(.title)
                            
                        }
                    }
                }
            } else {
                List {
                    ForEach(items) { item in
//                        NavigationLink {
//                            Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                        } label: {
//                            Text(item.timestamp!, formatter: itemFormatter)
//                        }
                        
                            Text(item.timestamp!, formatter: itemFormatter)
                    }
                    .onDelete(perform: deleteItems)
                }
                .navigationBarTitle("Speedometer")
                .toolbar {
                    ToolbarItem {
                        Button {
                            withAnimation {
                                isRecording.toggle()
                            }
                            locationService.locationManager.stopUpdatingLocation()
                            motionService.stopMotionUpdates()
                        } label: {
                            Label("Add Item", systemImage: "stop.circle")
                                .font(.title)
                        }
                    }
                }
            }
            Text("Select an item")
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
        var csvText = "timestamp,locationTimestamp,speed,speedAccuracy,ellipsodialAltidue,altitude,latitude,longitude,verticalAccuracy,horizontalAccuracy,course,courseAccuracy,floor, ,motionTimestamp,accelerationX,accelerationY,accelerationZ,rotationRateX,rotationRateY,rotationRateZ,magneticFieldAccuracy,magneticFieldX,magneticFieldY,magneticFieldZ\n"
        
        for item in items {
            let optionalDate = Date(timeIntervalSince1970: 0)
            csvText += "\(item.timestamp ?? optionalDate),\(item.timestampLocation ?? optionalDate),\(item.speed),\(item.speedAccuracy),\(item.ellipsoidalAltitude),\(item.altitude),\(item.latitude),\(item.longitude),\(item.verticalAccuracy),\(item.horizontalAccuracy),\(item.course),\(item.courseAccuracy),\(item.floor), ,\(item.timestampMotion ?? optionalDate),\(item.accelerationX),\(item.accelerationY),\(item.accelerationZ),\(item.rotationRateX),\(item.rotationRateY),\(item.rotationRateZ),\(item.magneticFieldAccuracy),\(item.magneticFieldX),\(item.magneticFieldY),\(item.magneticFieldZ)\n"
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
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
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
    }
}
