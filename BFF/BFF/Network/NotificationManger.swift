//
//  NotificationManger.swift
//  BFF
//
//  Created by yulin on 2021/10/27.
//

import Foundation

import UserNotifications
import FirebaseFirestore
import CoreData

class NotificationManger {

    static let shared = NotificationManger()

    var unuPool = UNUserNotificationCenter.current()

    // swiftlint:disable force_cast
    let app = UIApplication.shared.delegate as! AppDelegate
    // swiftlint:enable force_cast

    func setUp() {
        unuPool = app.center
    }

    func createSupplyNotification(supply: Supply) {

        let identifier = "Supply_\(supply.supplyId)"
        var title = ""
        if supply.forPets == [String]() {
            title = "來自毛小孩的通知"
        } else {
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

                let fetchRequests = NSFetchRequest<PetMO>(entityName: "Pet")
                fetchRequests.predicate = NSPredicate(format: "petId = %@", supply.forPets[0])
                let context = appDelegate.persistentContainer.viewContext
                do {
                    let pet = try context.fetch(fetchRequests)
                    title = "來自\(pet[0].name!)的通知"
                } catch {
                    fatalError("CodataERROR:\(error)")
                }

            }

        }

        let notification = Notification(content: "\(supply.supplyName)要沒囉～要記得幫我買~~~", notifyTime: Timestamp.init(date: Date()), fromPets: supply.forPets, title: title, type: "Supply", id: identifier)
        print("SetNotification: \(notification.notifyTime.dateValue())")

        setUNUserNotification(notification, supply, identifier)

    }

    func setUNUserNotification(_ notification: Notification, _ supply: Supply, _ identifier: String) {

        var setNotification = notification

        let content = UNMutableNotificationContent()
        content.title = setNotification.title
        content.body = setNotification.content
        content.sound = UNNotificationSound.default
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        let triggerDate = countNotifyDate(fullStock: supply.fullStock, stock: supply.stock, reminderPercent: supply.reminderPercent, perCycleTime: supply.perCycleTime, cycleTime: supply.cycleTime)
        
//        let trigger = UNTimeIntervalNotificationTrigger(time: TimeInterval(4), repeats: false)

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        guard let notifyTime = Calendar.current.date(from: triggerDate) else { return }

        setNotification.notifyTime = Timestamp(date: notifyTime)

        print("SetedNotification: \(setNotification.notifyTime.dateValue())")

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        unuPool.add(request, withCompletionHandler: { (error) in
            if let error = error {

                print("addNotificationError: \(error)")

            } else {

                print("addNotificationSuccess: \(setNotification.notifyTime)")
                FirebaseManager.shared.createNotification(newNotify: setNotification)
            }
        })
    }

    func countNotifyDate(fullStock: Int, stock: Int, reminderPercent: Double, perCycleTime: Int, cycleTime: String, fromDate: Date = Date()) -> DateComponents {

        let maxStockDo = Double(fullStock)
        let stockDo = Double(stock)
        let cycleConsumeDo = Double(perCycleTime)
        var triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(timeInterval: TimeInterval(4), since: Date()))

        guard stockDo > cycleConsumeDo else {
            return triggerDate
        }

        var notifyDateFromNow = (stockDo - (maxStockDo * (reminderPercent/100.0))) / cycleConsumeDo

        if notifyDateFromNow < 0 {
            notifyDateFromNow = 0
        } else {

        }

        switch cycleTime {

        case "每月":

            guard let notifyDate = Calendar.current.date(byAdding: .month, value: Int(notifyDateFromNow), to: fromDate) else { return triggerDate }
            triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notifyDate)

        case "每日":

            guard let notifyDate = Calendar.current.date(byAdding: .day, value: Int(notifyDateFromNow), to: fromDate) else { return triggerDate }
            triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notifyDate)

        default:
           break
        }
        triggerDate.hour = 18
        triggerDate.minute = 30
        return triggerDate
    }

    func deleteNotification(notifyId: String) {
        unuPool.removePendingNotificationRequests(withIdentifiers: ["Supply_\(notifyId)"])
        FirebaseManager.shared.removeNotification(notifyId: "Supply_\(notifyId)")
        UIApplication.shared.applicationIconBadgeNumber -= 1
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

        case "SnoozeAction" :
            print("Snooze")
            let identifier = "SnoozeNotification"
            let content = response.notification.request.content
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request, withCompletionHandler: {(error) in
                if let error = error {
                    print("\(error)")
                } else {
                    print("successes snooze")
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
