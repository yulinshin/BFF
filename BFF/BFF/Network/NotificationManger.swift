//
//  NotificationManger.swift
//  BFF
//
//  Created by yulin on 2021/10/27.
//

import Foundation

import UserNotifications
import FirebaseFirestore

class NotificationManger {

    static let shared = NotificationManger()

    var unuPool = UNUserNotificationCenter.current()

    let snoozeAction = UNNotificationAction(identifier: "SnoozeAction",
        title: "Snooze", options: [.authenticationRequired])
    let deleteAction = UNNotificationAction(identifier: "DeleteAction",
        title: "Delete", options: [.destructive])

    // swiftlint:disable force_cast
    let app = UIApplication.shared.delegate as! AppDelegate
    // swiftlint:enable force_cast

    func setUp(){

        let category = UNNotificationCategory(identifier: "NotificationCategory",
            actions: [snoozeAction,deleteAction],
            intentIdentifiers: [], options: [])
        unuPool = app.center
        unuPool.setNotificationCategories([category])
    }


    func creatSupplyNotification(supply:Supply){

        let identifier = "Supply_\(supply.supplyId)"

        let notifycation = Notification(content: "Defult", notifyTime: Timestamp.init(date: Date()), fromPets: [String](), title: "Title", type: "Supply", id: "identifier")

        setUNUserNotification(notifycation, supply, identifier)

        FirebaseManager.shared.creatNotification(newNotify: notifycation)

    }



    func setUNUserNotification(_ notifycation: Notification, _ supply: Supply, _ identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = notifycation.title
        content.body = notifycation.content
        content.sound = UNNotificationSound.default

        let date = countNotifyDate(fullStock: supply.fullStock, stock: supply.stock, reminderPercent: supply.reminderPercent, perCycleTime: supply.perCycleTime, cycleTime: supply.cycleTime)

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        //ForTese 10s
        let testTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: testTrigger)

        unuPool.add(request, withCompletionHandler: { (error) in
            if let error = error {

                print("addNotificationError: \(error)")

            }
        })
    }


    func countNotifyDate (fullStock:Int, stock:Int, reminderPercent:Double, perCycleTime:Int,  cycleTime:String) -> Date {

        let maxStockDo = Double(fullStock)
        let stockDo = Double(stock)
        let cycleComuseDo = Double(perCycleTime)

        guard stockDo > cycleComuseDo else {
            return Calendar.current.date(byAdding: .second, value: 10, to: Date()) ?? Date()
        }

        let notifyDateFromNow = (stockDo - (maxStockDo * (reminderPercent/100.0))) / cycleComuseDo

        switch cycleTime {

        case "每月":

            guard let notifyDate = Calendar.current.date(byAdding: .month, value: Int(notifyDateFromNow), to: Date()) else { return Date() }
            return notifyDate

        case "每日":

            guard let notifyDate = Calendar.current.date(byAdding: .day, value: Int(notifyDateFromNow), to: Date()) else { return Date() }
            return notifyDate

        default:
            return Date()
        }

    }


    func deleteNotification(notifyId:String){
        unuPool.removePendingNotificationRequests(withIdentifiers: ["Supply_\(notifyId)"])

        FirebaseManager.shared.removeNotification(notifyId: "Supply_\(notifyId)")



    }

}


class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound and show alert to the user
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")

        case "SnoozeAction":
            print("Snooze")
            let identifier = "SnoozeNotification"
            let content = response.notification.request.content
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request, withCompletionHandler: {(error) in
                if let error = error {
                    print("\(error)")
                }else {
                    print("successed snooze")
                }
            })

        case "DeleteAction":
            print("Delete")
        default:
            print("Unknown action")
        }

        completionHandler()
    }

}

