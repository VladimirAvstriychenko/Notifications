//
//  Notifications.swift
//  Notifications
//
//  Created by Владимир on 25.10.2020.
//

import UIKit
import UserNotifications
//Firebase +
import Firebase
//Firebase -
class Notifications: NSObject, UNUserNotificationCenterDelegate {

    let notificationCenter = UNUserNotificationCenter.current()
    //Firebase +
    let messagingDelegate = Messaging.messaging()
    //Firebase -
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print ("Permission granted \(granted)")
            guard granted else {return}
            self.getNotificationSettings()
        }
    }
    //
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings{(settings) in
            print("Notification settings: \(settings)")
            //PUSH +
            guard settings.authorizationStatus == .authorized else {return}
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            //PUSH -
        }
    }
    
    //
    func scheduleNotification(notificationType: String){
        
        let content = UNMutableNotificationContent()
        let userAction = "User Action"
        
        content.title = notificationType
        content.body = "This is example how to create " + notificationType
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = userAction
        
        guard let path = Bundle.main.path(forResource: "kr", ofType: "jpg") else {return}
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let attachment = try UNNotificationAttachment(
            identifier: "kr",
            url: url,
            options: nil)
            content.attachments = [attachment]
        } catch {
            print("The attachment could not be loaded!")
        }
//        let date = Date(timeInterval: 1, since: Date())
//        let trigger = Dat
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request){(error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: userAction,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        notificationCenter.setNotificationCategories([category]) // Тут квадратные скобки нужны, так как это сет - множество
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notification with the Local Notification Identifier")
        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismissed")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
            scheduleNotification(notificationType: "Reminder")
        case "Delete":
            print("Delete")
        default:
            print("Unknown action")
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
}

//Firebase +
extension Notifications: MessagingDelegate{
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print ("\n\nFirebase registration token: \(fcmToken ?? "")\n\n")
    }

}
//Firebase -
