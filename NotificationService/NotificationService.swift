//PUSH +
//
//  NotificationService.swift
//  NotificationService
//
//  Created by Владимир on 05.12.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UserNotifications

//class NotificationService: UNNotificationServiceExtension {
//
//    var contentHandler: ((UNNotificationContent) -> Void)?
//    var bestAttemptContent: UNMutableNotificationContent?
//
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void){
//        print("Receiving...")
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//
//        //PUSH +
//        //WAS:
////        if let bestAttemptContent = bestAttemptContent {
////            // Modify the notification content here...
////            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
////
////            contentHandler(bestAttemptContent)
////        }
//        //BECAME:
//        guard let bestAttemptContent = bestAttemptContent,
//        let apsData = bestAttemptContent.userInfo["aps"] as? [String: Any],
//        let attachmetnURLAsString = apsData["attachment-url"] as? String,
//        let attachmentUrl = URL(string: attachmetnURLAsString) else {return}
//
//        downloadImageFrom(url: attachmentUrl) {(attachment) in
//            if attachment != nil {
//                bestAttemptContent.attachments = [attachment!]
//                contentHandler(bestAttemptContent)
//            }
//        }
//        //PUSH -
//    }
//
//    override func serviceExtensionTimeWillExpire() {
//        // Called just before the extension will be terminated by the system.
//        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//            contentHandler(bestAttemptContent)
//        }
//    }
//
//}
//
// //MARK : - Helper Fucntions
//extension NotificationService {
//    private func downloadImageFrom(url: URL, with completionHandler: @escaping(UNNotificationAttachment?) -> Void){
//        print("Downloading...")
//        let task = URLSession.shared.downloadTask(with: url) { (downloadUrl, response, error) in
//            guard let downloadUrl = downloadUrl else {
//                completionHandler(nil)
//                return
//            }
//            var urlPath = URL(fileURLWithPath: NSTemporaryDirectory())
//
//            let uniqueURLEnding = ProcessInfo.processInfo.globallyUniqueString + ".png"
//            urlPath = urlPath.appendingPathComponent(uniqueURLEnding)
//
//            try? FileManager.default.moveItem(at: downloadUrl, to: urlPath)
//
//            do {
//                let attachment = try UNNotificationAttachment(identifier: "favicon", url: urlPath, options: nil)
//                completionHandler(attachment)
//            } catch {
//                completionHandler(nil)
//            }
//        }
//        task.resume()
//    }
//}

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent,
        let apsData = bestAttemptContent.userInfo["aps"] as? [String: Any],
        let attachmentURLAsString = apsData["attachment-url"] as? String,
        let attachmentUrl = URL(string: attachmentURLAsString) else { return }
        
        downloadImageFrom(url: attachmentUrl) { (attachment) in
            if attachment != nil {
                bestAttemptContent.attachments = [attachment!]
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

//MARK: - Helper Functions
extension NotificationService {
    
    private func downloadImageFrom(url: URL, with completionHandler: @escaping(UNNotificationAttachment?) -> Void) {
     
        let task = URLSession.shared.downloadTask(with: url) { (downloadUrl, response, error) in
            
            guard let downloadUrl = downloadUrl else {
                completionHandler(nil)
                return
            }
            
            var urlPath = URL(fileURLWithPath: NSTemporaryDirectory())
            
            print("third test")
            
            let uniqueURLEnding = ProcessInfo.processInfo.globallyUniqueString + ".png"
            urlPath = urlPath.appendingPathComponent(uniqueURLEnding)
            
            try? FileManager.default.moveItem(at: downloadUrl, to: urlPath)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "favicon", url: urlPath, options: nil)
                completionHandler(attachment)
            } catch {
                completionHandler(nil)
            }
        }
        task.resume()
    }
}
//PUSH -
