//
//  UpdatesApp.swift
//  Updates
//
//  Created by Jake Martin on 6/5/23.
//

import SwiftUI
import CoreData

@main
struct UpdatesApp: App {
    
    // MARK: - Properties
    
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1000.0, minHeight: 550.0)
                .environment(\.managedObjectContext,
                              dataController.container.viewContext)
                .environmentObject(dataController)
            
        }
    }

}
