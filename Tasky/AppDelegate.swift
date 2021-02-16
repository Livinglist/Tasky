//
//  AppDelegate.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import Foundation
import Firebase
import UIKit
import SwURL

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure FirebaseApp
        FirebaseApp.configure()
        SwURL.setImageCache(type: .inMemory)
        return true
    }
    
    func application(_ application: UIApplication , didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        if Auth.auth().canHandleNotification(notification)
        {
            completionHandler(UIBackgroundFetchResult.noData);
            return
        }
    }
}
