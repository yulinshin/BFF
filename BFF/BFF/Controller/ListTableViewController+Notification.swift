//
//  ListTableViewController+Notification.swift
//  BFF
//
//  Created by yulin on 2021/10/27.
//

import UIKit
import UserNotifications

extension ListTableViewController {
//
//    func sendNotification(titleText: String, bodyText: String) {
//        // Main thread checker
//        DispatchQueue.main.async {
//
//                let customID = titleText
//                let identifier = "Notification"
//                let content = UNMutableNotificationContent()
//                content.title = titleText
//                content.body = bodyText
//                content.sound = UNNotificationSound.default
//                content.badge = NSNumber(integerLiteral: UIApplication.shared.applicationIconBadgeNumber + 1)
//                content.categoryIdentifier = "NotificationCategory"
//
////                    let timeInterval = self.triggerTimePicker.countDownDuration
//                // for testing the timeInterval set to 10 sec
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
//
//                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//                self.center?.add(request, withCompletionHandler: {(error) in
//                    if let error = error {
//                        print("\(error)")
//                    }else {
//                        print("successed")
//                    }
//                })
//
//        }
//
//
//    }

//    func emptyAlert() {
//        let controller = UIAlertController(title: "Warning", message: "Title or Body can't be empty!", preferredStyle: .alert)
//        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//        controller.addAction(action)
//
//        self.present(controller, animated: true, completion: nil)
//    }
//
//    func deniedAlert() {
//
//        // swiftlint:disable:next line_length
//        let useNotificationsAlertController = UIAlertController(title: "Turn on notifications", message: "This app needs notifications turned on for the best user experience \n ", preferredStyle: .alert)
//
//        // go to setting alert action
//        let goToSettingsAction = UIAlertAction(title: "Go to settings", style: .default, handler: { (action) in
//            guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
//            if UIApplication.shared.canOpenURL(settingURL) {
//                UIApplication.shared.open(settingURL, completionHandler: { (success) in
//                    print("Settings opened: \(success)")
//                })
//            }
//        })
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
//        useNotificationsAlertController.addAction(goToSettingsAction)
//        useNotificationsAlertController.addAction(cancelAction)
//
//        self.present(useNotificationsAlertController, animated: true)
//    }
}
