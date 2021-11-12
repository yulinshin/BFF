//
//  HomePageView.swift
//  BFF
//
//  Created by yulin on 2021/10/21.
//

import Foundation
import CoreData
import UIKit

class HomePageViewModel: NSObject {

    var user: User?
    let userName = Box("")
    let notifiactions = Box([Notification]())
    let pets = Box([Pet]())
    let usersPetsIds = Box([String]())
    var userDataDidLoad: (() -> Void)?
    var userNotifiactionsDidChange: (() -> Void)?


    override init() {
        super.init()
        self.fetchUserData()
        self.fetchNotificationData()
    }

    deinit {
        print("HomePageViewModel DIE")
    }

    func fetchUserData() {

        FirebaseManager.shared.fetchUser { result in

            switch result {

            case .success(let user):

                self.user = user

                self.userName.value = user.userName

                self.usersPetsIds.value = user.petsIds ?? [String]()

                print("upDate UserData at HomeVM")


                // Update data to Local

                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {


                    let context = appDelegate.persistentContainer.viewContext
                    do {
                        var requests = try context.fetch(UserMO.fetchRequest())

                        if requests.isEmpty {
                            let userMo = UserMO(context:
                                                    appDelegate.persistentContainer.viewContext)
                            userMo.name = user.userName
                            print("HEEEEEEEE\(user.userName)")
                            userMo.petsIds = user.petsIds
                            userMo.userId = user.userId

                            appDelegate.saveContext()

                        } else {
                        for request in requests {

                            if request.userId == user.userId {
                                request.name = user.userName
                                request.petsIds = user.petsIds
                            } else {
                                request.userId = user.userId
                                request.name = user.userName
                                request.petsIds = user.petsIds
                            }
                            appDelegate.saveContext()
                        }
                    }
                    } catch {
                        fatalError("CodataERROR:\(error)")
                    }

                }

                self.fetchUserPetsData()

            case .failure(let error):

                print("Can't Get User Info \(error)")

            }

        }
    }


    func fetchUserPetsData() {

        FirebaseManager.shared.fetchUserPets { result in

            switch result {

            case .success(let pets):

                self.pets.value = pets
                self.userDataDidLoad?()

                print("upDate UserPetsData at HomeVM")

                // Update data to Local

                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

                    pets.forEach { pet in
                        let context = appDelegate.persistentContainer.viewContext
                        do {
                            var requests = try context.fetch(PetMO.fetchRequest())
                            var isContain = false

                            for request in requests {
                                if request.petId == pet.petId {
                                    request.name = pet.name
                                    request.thumbNail?.fileName = pet.petThumbnail?.fileName
                                    request.thumbNail?.url = pet.petThumbnail?.url
                                    isContain = true
                                }
                                appDelegate.saveContext()
                            }

                            if isContain == false {
                                let petMo = PetMO(context: appDelegate.persistentContainer.viewContext)
                                petMo.name = pet.name
                                let picMo = PicMO(context: appDelegate.persistentContainer.viewContext)
                                picMo.url = pet.petThumbnail?.url
                                picMo.fileName = pet.petThumbnail?.fileName
                                petMo.thumbNail = picMo
                                petMo.petId = pet.petId
                                appDelegate.saveContext()
                            }

                        } catch {
                            fatalError("\(error)")
                        }
                    }

                }

                //

            case .failure(let error):

                print("Can't Get Pets Data \(error)")

            }

        }
    }

    func fetchNotificationData() {

        FirebaseManager.shared.fetchNotifications { result in

            switch result {

            case .success(let notifications):

                var showNotifications = [Notification]()
                notifications.forEach { notification in
                    if notification.notifyTime.dateValue() < Date(){
                        print("Notify:\(notification.notifyTime.dateValue())")
                        print("now:\(Date())")
                        showNotifications.append(notification)
                    }
                }

                showNotifications = showNotifications.sorted(by:{ $0.notifyTime.dateValue() > $1.notifyTime.dateValue()})

                self.notifiactions.value = showNotifications

                self.userNotifiactionsDidChange?()
                print("upDated NotificationData at HomeVM")

            case .failure(let error):

                print("Can't Get Notifications Data \(error)")

            }

        }

    }

    func listenNotificationData() {

        FirebaseManager.shared.listenNotifications { result in

            switch result {

            case .success(let notifications):

                var showNotifications = [Notification]()
                notifications.forEach { notification in
                    if notification.notifyTime.dateValue() < Date(){
                        showNotifications.append(notification)
                }
                }
                showNotifications = showNotifications.sorted(by:{ $0.notifyTime.dateValue() > $1.notifyTime.dateValue()})
                self.notifiactions.value = showNotifications

                self.userNotifiactionsDidChange?()
                print("upDated NotificationData at HomeVM")

            case .failure(let error):

                print("Can't Get Notifications Data \(error)")

            }

        }

    }

    func listenUsersPets() {

        print("Perpare to listen UsersPets at HomeVM........")

        FirebaseManager.shared.listenUsersPets { result in

            switch result {

            case .success(let pets):

                self.pets.value = pets
                self.userDataDidLoad?()

            case .failure(let error):

                print("Can't Get Pets Data \(error)")

            }

        }

    }

    func listenUserData() {

        print("Perpare to listen UserData at HomeVM........")

        FirebaseManager.shared.listenUser { result in

            switch result {

            case .success(let user):

                self.userName.value = user.userName

                self.usersPetsIds.value = user.petsIds ?? [String]()

                print("upDated UserData at HomeVM")

                self.fetchUserPetsData()

            case .failure(let error):

                print("Can't Get User Info \(error)")

            }

        }

    }
}

extension HomePageViewModel: NSFetchedResultsControllerDelegate {

}
