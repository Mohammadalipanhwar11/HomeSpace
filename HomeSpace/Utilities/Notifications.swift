//
//  Notifications.swift
//  HomeSpace
//
//  Created by Fahad Saleem on 11/9/19.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import Foundation
import UserNotifications

class Notifications: NSObject, UNUserNotificationCenterDelegate
{
    let notificationCenter = UNUserNotificationCenter.current()

    
    func notificationRequest()
    {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options)
        {
            (success, error) in
            
            if success == true
            {
                
            }
            else
            {
                print(error!.localizedDescription)
                print("User Has Declined Notification")
            }
        }
        
        notificationCenter.getNotificationSettings
            {
                (settings) in
                
                switch settings.authorizationStatus
                {
                case .authorized:
                    print("Authorized")
                case .denied:
                    print("Denied")
                case .notDetermined:
                    print("Not Determined")
                case .provisional:
                    print("Provisional")
                default:
                    print("Default")
                }
        }
        
        func scheduleNotification(notificationType: String, body:String, time: Date) {
            
            let content = UNMutableNotificationContent()
            
            content.title = "Reminder"
            content.body  = "This is example how to create"
            content.sound = UNNotificationSound.default
            content.badge = 1
            //content.categoryIdentifier = categoryIdentifier
            
            let date = time
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let identifier = "HomeSpace"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            //NOTE: This function will override the previous notification if the identifier is same, in order for multiple notifications to be up at the same time we need to differentiate them with different identifiers.
            
            notificationCenter.add(request)
            {
                (error) in
                if let error = error
                {
                    print("Error \(error.localizedDescription)")
                }
            }
            
            
            
        }
    }
}
