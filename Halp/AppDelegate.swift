//
//  AppDelegate.swift
//  Halp
//
//  Created by Andrew Lisowski on 1/27/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

var pinMode = "student"
var thisDeviceToken:NSData!
let halpApi = HalpAPI()
let teal = UIColor(red: 136/255, green: 205/255, blue: 202/255, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Whenever a person opens the app, check for a cached session FBSessionStateCreatedTokenLoaded
        FBLoginView.self
        FBProfilePictureView.self
        
        // create viewController code...
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! ViewController
        let leftViewController = storyboard.instantiateViewControllerWithIdentifier("LeftViewController") as! LeftViewController
        let nvc = UINavigationController(rootViewController: mainViewController)
        let rightViewController = storyboard.instantiateViewControllerWithIdentifier("NotificationList") as! UITableViewController
        
        leftViewController.mainViewController = nvc
        leftViewController.nav = nvc

        
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController, rightMenuViewController: rightViewController)
        
        self.window?.backgroundColor = teal
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        
        var type = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
        var setting = UIUserNotificationSettings(forTypes: type, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(setting)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        Braintree.setReturnURLScheme("halp.Halp.payments")
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        thisDeviceToken = deviceToken
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Failed to register for remote notifcations")
        println(error.localizedDescription)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // Notification RECIEVED
        notificationCounts = userInfo as! [String : AnyObject]
        let count = notificationCounts["count"] as! Int
        println("notification recieved")
        let events = notificationCounts["events"] as! [String]
        UIApplication.sharedApplication().applicationIconBadgeNumber = count
        
        NSNotificationCenter.defaultCenter().postNotificationName("notificationsRecieved", object: nil, userInfo: userInfo)
        if (userInfo["session"] != nil) {
            NSNotificationCenter.defaultCenter().postNotificationName("inSession", object: nil, userInfo: userInfo)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("GetNewMessages", object: nil, userInfo: userInfo)
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if(sourceApplication == "com.facebook.Facebook") {
            return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        } else {
            return Braintree.handleOpenURL(url, sourceApplication: sourceApplication)
        }
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
}

