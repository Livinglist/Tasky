//
//  AppDelegate.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import Foundation
import Firebase
import FontAwesomeSwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure FirebaseApp
        FontAwesome.register()
        FirebaseApp.configure()
        return true
    }
}
