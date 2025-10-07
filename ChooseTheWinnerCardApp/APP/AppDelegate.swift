import Foundation
import UIKit


import SwiftUI
import OneSignalFramework


@main

class AppDelegate: UIResponder, UIApplicationDelegate {
  
    
   static var orientationLock =
   UIInterfaceOrientationMask.all

   func application(_ application: UIApplication,
   supportedInterfaceOrientationsFor window:
   UIWindow?) -> UIInterfaceOrientationMask {
   return AppDelegate.orientationLock
   }
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       OneSignal.initialize("9c75e647-4ab3-4b93-ad47-2e3fa748cb0a", withLaunchOptions: launchOptions)
       OneSignal.Notifications.requestPermission({ accepted in
           print("User accepted notifications: \(accepted)")
       }, fallbackToSettings: true)

       return true
   }

   func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
       return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
   }

   func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
 
       
   }

    

   
   

}

