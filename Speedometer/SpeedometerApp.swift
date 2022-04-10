//
//  SpeedometerApp.swift
//  Speedometer
//
//  Created by Thomas on 10.04.22.
//

import SwiftUI

@main
struct SpeedometerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
