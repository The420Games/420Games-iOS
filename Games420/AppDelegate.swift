//
//  AppDelegate.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 12..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Strava app properties
    fileprivate let stravaAppId = "12445"
    fileprivate let stravaClientSecret = "ba8db7f558bc1704ea5394c1a47d167d44f1e359"
    
    // Crashlytics
    fileprivate let crashlyticsKey = "6ba381b8a208506b0d983661e196544c9eebe468"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        Crashlytics.start(withAPIKey: crashlyticsKey)
        
        FTAnalytics.initAnalytics()
        
        FTStravaManager.sharedInstance.appID = stravaAppId
        FTStravaManager.sharedInstance.clientSecret = stravaClientSecret
        
        FTDataManager.initBackend()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        setupUI()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        FTStravaManager.sharedInstance.handleOpenURL(url)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Global UI customizations
    
    fileprivate func setupUI() {

        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.defaultFont(.medium, size: 18.7)!
        ]
        
        //UIFont.printFonts()
    }

}

