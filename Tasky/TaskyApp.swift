//
//  TaskyApp.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import SwiftUI

@main
struct TaskyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
