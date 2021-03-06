//
//  AppDelegate.swift
//  Doya
//
//  Created by vortispy on 2014/08/10.
//  Copyright (c) 2014年 vortispy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var mainViewController : UIViewController?

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        if let redis = createRedisWithPropertyList(){
            DSRedis.setSharedRedis(redis)
        } else{
            return false
        }
        /*
        let storyboard = self.window?.rootViewController?.storyboard
        let kiyaku = storyboard?.instantiateViewControllerWithIdentifier("kiyaku") as UIViewController
        mainViewController = self.window?.rootViewController
        if true {
            self.window?.rootViewController = kiyaku
            self.exchangeRootViewController()
        }
*/
        // Override point for customization after application launch.
        return true
    }
    
    func createRedisWithPropertyList() -> DSRedis? {
        let url = NSBundle.mainBundle().URLForResource("secrets", withExtension: "plist");
        let dict = NSDictionary(contentsOfURL: url!);

        if let host = dict["redis-host"] as? NSString{
            if let port = dict["redis-port"] as? UInt {
                let pass = dict["redis-pass"] as NSString?
                return DSRedis(server: host, port: port, password: pass)
            }
        }
        
        return nil
    }


    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
            }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if DSRedis.sharedRedis().ping() == false{
            abort()
        }
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

