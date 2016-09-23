//
//  AppDelegate.swift
//  AWSBased_SwiftAppDemo
//
//  Created by Dmytro Kabyshev on 9/21/16.
//  Copyright © 2016 HillTrix sp. z o.o. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SVProgressHUD

typealias ViewController = UIViewController
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootFlowCoordinator: RootFlowCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance()
            .application(application, didFinishLaunchingWithOptions: launchOptions)
        // Optionally add to ensure your credentials are valid:
        FBSDKLoginManager.renewSystemCredentials {
            (result, error) in
        }
        
        SVProgressHUD.setDefaultMaskType(.gradient)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        // We have a dedicated dump viewcontroller to use as bottom cover for switching screens
        let root = R.storyboard.main.rootView()!
        rootFlowCoordinator = RootFlowCoordinator(parent: root)
        self.window?.rootViewController = root
        self.window?.makeKeyAndVisible()

        DispatchQueue.main.async {
            self.rootFlowCoordinator.present() // start the root flow
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Even though the Facebook SDK can make this determinitaion on its own,
        // let's make sure that the facebook SDK only sees urls intended for it,
        // facebook has enough info already!

        let isFacebookURL = (url.scheme?.hasPrefix("fb\(FBSDKSettings.appID() ?? "")") ?? false) && url.host == "authorize"
        if isFacebookURL {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                         open: url,
                                                                         sourceApplication: sourceApplication,
                                                                         annotation: annotation)
        }
        
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension UIApplication {
    static var activity: Bool {
        get {
            return UIApplication.shared.isNetworkActivityIndicatorVisible
        }
        set(newValue) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }
    
    class func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let currentBase = base == nil ? (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController : base
        if let nav = currentBase as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = currentBase as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = currentBase?.presentedViewController {
            return topViewController(base: presented)
        }
        return currentBase
    }
}

