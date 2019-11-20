//
//  AppDelegate.swift
//  HomeSpace
//
//  Created by axiom1234 on 13/03/2019.
//

import UIKit
import Firebase
import FirebaseAuth
import IQKeyboardManagerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var currentUser:User?
    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        notificationCenter.delegate = self
        if Auth.auth().currentUser != nil
        {
            let storyboard:UIStoryboard = UIStoryboard(name: "Auth", bundle: nil)
            let rootViewController:UINavigationController = storyboard.instantiateViewController(withIdentifier: "VC") as! UINavigationController
            
            let mainStory = UIStoryboard(name: "Main", bundle: nil)
            let main  = mainStory.instantiateViewController(withIdentifier: "main") as! UIViewController
            rootViewController.viewControllers.append(main)
            self.window?.rootViewController = rootViewController
        }
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options)
        {
            (didAllow, error) in
            
            if didAllow == true
            {
                print("Allowed")
            }
            else
            {
                print(error!.localizedDescription)
            }
            
        }
        //IQKeyboardManager.shared.enable = true
        
        //        taskManager.shared.updateMaxOrder()
        //  taskManager.shared.add()
        
        return true
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        
        
        // first launch
        // this method is called only on first launch when app was closed / killed
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // app will enter in foreground
        // this method is called on first launch when app was closed / killed and every time app is reopened or change status from background to foreground (ex. mobile call)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // app becomes active
        // this method is called on first launch when app was closed / killed and every time app is reopened or change status from background to foreground (ex. mobile call)
    }
    
    
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notification = response.notification
        var  dict = UserDefaults.standard.value(forKey: "dict") as! [String:String]
        
        switch response.actionIdentifier {
        case "Snooze":
            let body = notification.request.content.body
            _scheduleNotification(notificationType: "Reminder", time: Date.init(timeIntervalSinceNow: 5), body: body, groupID: dict[notification.request.content.body]!, taskID: "1", UID: "vsvs")
            center.removeAllDeliveredNotifications()
        case "DeleteAction":
            center.removeAllDeliveredNotifications()
            taskManager.shared.deleteReminder(taskID: dict["_"+notification.request.content.body]!)
            dict[notification.request.content.body] = nil
            dict["_"+notification.request.content.body] = nil
            UserDefaults.standard.set(dict, forKey: "dict")
        default:
            var  dict = UserDefaults.standard.value(forKey: "dict") as! [String:String]
            dict["openGroup"] = dict[notification.request.content.body]
            taskManager.shared.deleteReminder(taskID: dict["_"+notification.request.content.body]!)
            dict[notification.request.content.body] = nil
            dict["_"+notification.request.content.body] = nil
            UserDefaults.standard.set(dict, forKey: "dict")
            if let vc = staticLinker.rootVc{
                vc.managePageController()
            }
        }
        completionHandler()
    }
    
    func _scheduleNotification(notificationType: String, time:Date, body:String, groupID: String, taskID : String,UID: String) {
        
        UIApplication.shared.applicationIconBadgeNumber += 1
        let content = UNMutableNotificationContent() // Содержимое уведомления
        let categoryIdentifire = "Delete Notification Type"
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        _ = dateFormatter.string(from: time)
        content.title = notificationType
        content.body = body
//        content.sound = UNNotificationSound.default
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "chime.mp3"))
        
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire

        let date = time
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let identifier = "HomeSpace"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifire,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    func scheduleNotification(notificationType: String, time:Date, body:String, groupID: String, taskID : String,UID: String) {
        
        UIApplication.shared.applicationIconBadgeNumber += 1
        let content = UNMutableNotificationContent() // Содержимое уведомления
        let categoryIdentifire = "Delete Notification Type"
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: time)
        content.title = notificationType
        content.body = "You have a reminder at \(strDate) from \(body)"
//        content.sound = UNNotificationSound.default
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "chime.mp3"))
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        /////////////
        if let dict = UserDefaults.standard.value(forKey: "dict") as? [String:String]{
            var dict = dict
            dict["You have a reminder at \(strDate) from \(body)"] = groupID
            dict["_You have a reminder at \(strDate) from \(body)"] = taskID
            UserDefaults.standard.set(dict, forKey: "dict")
        }else{
            var dict = [String:String]()
            dict["You have a reminder at \(strDate) from \(body)"] = groupID
            dict["_You have a reminder at \(strDate) from \(body)"] = taskID
            UserDefaults.standard.set(dict, forKey: "dict")
        }
        /////////////

        let date = time
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let identifier = "HomeSpace"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Done", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifire,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
}

