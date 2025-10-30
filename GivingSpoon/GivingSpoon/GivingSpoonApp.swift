//
//  GivingSpoonApp.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@main
struct MealWizardApp: App {
    @StateObject var dataManager = DataManager()
    // Register AppDelegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        // print("DEBUG: Firestore root path: \(Firestore.firestore().databaseID)")
        WindowGroup {
            HomeView()
                .environmentObject(dataManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        print("DEBUG: Firestore instance at launch:", db)
        
        return true
    }
}
