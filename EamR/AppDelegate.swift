//
//  AppDelegate.swift
//  EamR
//
//  Created by Apple on 11/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
// cd ~/Desktop/Saravanan/rgTechProjects/Exhibition/profect/projectSwift/EamR/

import UIKit
import FBSDKLoginKit
import GGLSignIn
import GoogleSignIn
import IQKeyboardManagerSwift
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, SWRevealViewControllerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var HUD: MBProgressHUD?
    var strDeviceToken : String = ""


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //splashAnimate()
        
        UserDefaults.standard.set(false, forKey: "launchedBefore")
        
        HUD = MBProgressHUD(view: window!)
        
        IQKeyboardManager.sharedManager().enable = true
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        GIDSignIn.sharedInstance().delegate = self

        /*PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "AWhKmULoOegJHwzwfq3bAKRI-y-cRM3T00V2R5Gc0gRe7UyzLwIUvGVhVRAw71PmZPmnwCafIj_d8WPs",
                                                                PayPalEnvironmentSandbox: "AbBZrdrL57lHb6FG0P83EXW2StYhIqGg9DHJLN2qGJSmPB3x29HYfWHMZg1utAP3d3D-ZfRuO3a8BSSE"])*/
        // Client Id ***
        PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "AWhKmULoOegJHwzwfq3bAKRI-y-cRM3T00V2R5Gc0gRe7UyzLwIUvGVhVRAw71PmZPmnwCafIj_d8WPs",
                                                                PayPalEnvironmentSandbox: "AbBZrdrL57lHb6FG0P83EXW2StYhIqGg9DHJLN2qGJSmPB3x29HYfWHMZg1utAP3d3D-ZfRuO3a8BSSE"])
        
        let reveal: SWRevealViewController? = (window?.rootViewController as? SWRevealViewController)
        reveal?.delegate = self
        
        registerForRemoteNotification()
        //UserDefaults.standard.set(self.strDeviceToken, forKey:"deviceTocken")
        
        // Override point for customization after application launch.
        return true
    }

    class func showProgress(forState status: Bool) {
        let appDel: AppDelegate? = (UIApplication.shared.delegate as? AppDelegate)
        appDel?.showProgress(status)
    }
    
    
    func showProgress(_ staus: Bool) {
        if staus {
            HUD?.labelText = "Loading..."
            window?.addSubview(HUD!)
            HUD?.show(staus)
        }
        else {
            HUD?.removeFromSuperview()
            HUD?.hide(staus)
        }
    }
    
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition) {
        if position == FrontViewPosition.left {
            revealController.frontViewController.view.isUserInteractionEnabled = true
            revealController.frontViewController.revealViewController().tapGestureRecognizer()
            revealController.frontViewController.revealViewController().panGestureRecognizer()
        }
        else {
            revealController.frontViewController.view.isUserInteractionEnabled = false
        }
    }

    func revealController(_ revealController: SWRevealViewController, didMoveTo position: FrontViewPosition) {
        if position == FrontViewPosition.left {
            revealController.frontViewController.view.isUserInteractionEnabled = true
            revealController.frontViewController.revealViewController().tapGestureRecognizer()
            revealController.frontViewController.revealViewController().panGestureRecognizer()
        }
        else {
            revealController.frontViewController.view.isUserInteractionEnabled = false
        }
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let checkFB = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        let checkGoogle = GIDSignIn.sharedInstance().handle(url as URL!,sourceApplication: sourceApplication,annotation: annotation)
        return checkGoogle || checkFB
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Do nothing
        } else {
            print("\(error.localizedDescription)")
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
         FBSDKAppEvents.activateApp()
        
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


    func showProgress(a: Any) -> Any {
        return AppDelegate.showProgress(forState: a as! Bool)
    }
    
    
    // MARK: Remote Notification Methods // <= iOS 9.x
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let chars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var token = ""
        
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [chars[i]])
        }
        
        
        self.strDeviceToken = token
        UserDefaults.standard.set(self.strDeviceToken, forKey:"deviceTocken")
        print("Device Token = ", UserDefaults.standard.value(forKey: "deviceTocken") as! String)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Push Error = ",error.localizedDescription)
        #if TARGET_IPHONE_SIMULATOR
            self.strDeviceToken = "simulator"
            print("This is Simulator")
        #else

        #endif
        
        UserDefaults.standard.set(self.strDeviceToken, forKey:"deviceTocken")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        
        var dict = ["alert": userInfo["aps.alert"], "userId": userInfo["person.friendid"], "name": userInfo["person.name"]] as NSDictionary
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RecievedMessageinChatList"), object: nil)
        //var dict = ["alert": userInfo["aps"]["alert"], "facebookId": userInfo["person"]["friendid"], "name": userInfo["person"]["name"]]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MessageRecievedInChatScreen"), object: dict)

    }
    
    // MARK: UNUserNotificationCenter Delegate // >= iOS 10
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info = ",notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RecievedMessageinChatList"), object: nil)
        var dict = ["alert": notification.request.content.userInfo["aps.alert"], "facebookId": notification.request.content.userInfo["person.friendid"], "name": notification.request.content.userInfo["person.name"]]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MessageRecievedInChatScreen"), object: dict)
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info = ",response.notification.request.content.userInfo)
        completionHandler()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RecievedMessageinChatList"), object: nil)
        var dict = ["alert": response.notification.request.content.userInfo["aps.alert"], "facebookId": response.notification.request.content.userInfo["person.friendid"], "name": response.notification.request.content.userInfo["person.name"]]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MessageRecievedInChatScreen"), object: dict)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadChatList(_:)), name: NSNotification.Name(rawValue: "RecievedMessageinChatList"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadChatPaget(_:)), name: NSNotification.Name(rawValue: "MessageRecievedInChatScreen"), object: nil)
        
    }
    
    // MARK: Class Methods
    
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


