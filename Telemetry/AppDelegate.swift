//
//  AppDelegate.swift
//  Telemetry
//
//  Created by Agentum on 06.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let AUTH_CONTROLLER_ID = "authorizationControllerID"
    static let CONTAINER_CONTROLLER_ID = "containerControllerID"

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        initializeServices()
        setAppearanceForUIElements()
        setInitialVC()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: Functions
    func initializeServices(){
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyA5s150KB5KFgRFS5XgR_-ag3taHccOXkE")
    }
    
    func setAppearanceForUIElements(){
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "nav_bar"), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
    }
    
    func setInitialVC(){
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let _ = ApplicationState.sharedInstance().getToken(){
            let containerVC = mainStoryboard.instantiateViewControllerWithIdentifier("containerControllerID") as! ContainerViewController
            self.window?.rootViewController = containerVC
        } else {
            let authVC = mainStoryboard.instantiateViewControllerWithIdentifier("authorizationControllerID") as! AuthorizationViewController
            self.window?.rootViewController = authVC
        }
        self.window?.makeKeyAndVisible()

    }
}

