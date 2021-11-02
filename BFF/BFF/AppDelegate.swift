//
//  AppDelegate.swift
//  BFF
//
//  Created by yulin on 2021/10/17.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import Firebase
import FirebaseMessaging
import CoreData
import GoogleMaps
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let center = UNUserNotificationCenter.current()

        // delegate for receiving or delivering notification
    let notificationDelegate = NotificationDelegate()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        Messaging.messaging().delegate = self
        GMSServices.provideAPIKey("AIzaSyCuIEN8YUXa-OS0S5L2nOW_O__u4NfzfdY")
        GMSPlacesClient.provideAPIKey("AIzaSyCuIEN8YUXa-OS0S5L2nOW_O__u4NfzfdY")

        center.delegate = notificationDelegate

               // MARK: set authorization
               let options: UNAuthorizationOptions = [.badge, .sound, .alert]
               center.getNotificationSettings { ( settings ) in
                   switch settings.authorizationStatus {
                   case .notDetermined:
                       self.center.requestAuthorization(options: options) {
                           (granted, error) in
                           if !granted {
                               print("Something went wrong")
                           }
                       }
                   case .authorized:
                       DispatchQueue.main.async(execute: {
                           UIApplication.shared.registerForRemoteNotifications()
                       })
                   case .denied:
                       print("cannot use notifications cuz the user has denied permissions")

                   case .provisional:
                       break
                   case .ephemeral:
                       break
                   @unknown default:
                       break
                   }
               }


        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let deviceTokenString = deviceToken.reduce("") {
            $0 + String(format: "%02x", $1)
        }
        print("deviceToken", deviceTokenString)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "UserData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("CoreData:Unresolved error \(error), \(error.userInfo)")
            }
        })
        print("CordDataLocation: \(NSPersistentContainer.defaultDirectoryURL())")
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {

                try context.save()

            } catch {

                let nserror = error as NSError
                fatalError("CoreData:Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("fcm Token", fcmToken ?? "")
        // 將 fcm token 傳送給後台
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 使用者點選推播時觸發
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function)
        let content = response.notification.request.content
        print(content.userInfo)
        completionHandler()
    }

    // 讓 App 在前景也能顯示推播
    // swiftlint:disable:next line_length
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner])
        } else {
            // Fallback on earlier versions
        }
    }
}

