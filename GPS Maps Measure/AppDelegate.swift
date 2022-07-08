//
//  AppDelegate.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 27/6/22.
//

import UIKit
import CocoaLumberjackSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let fileLogger: DDFileLogger = DDFileLogger()
    let dataController = DataController(modelName: "GpsMaps")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DDOSLogger.sharedInstance.logFormatter = CustomLogFormatter()
        DDLog.add(DDOSLogger.sharedInstance)
        DDLogVerbose("Initial log setup")
    
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
    
        DDLog.add(fileLogger)

        dataController.load()
        
        if UserPref.createDefaultGroupIsNeeded() {
            let group = Group(context: dataController.viewContext)
            group.name = "Default"
            group.color = Int64(UIColor.blue.rgb()!)
            try? dataController.viewContext.save()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

