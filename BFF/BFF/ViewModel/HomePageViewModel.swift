//
//  HomePageView.swift
//  BFF
//
//  Created by yulin on 2021/10/21.
//

import Foundation
import CoreData
import UIKit
import Kingfisher
import AVFoundation

class HomePageViewModel: NSObject {

    enum Section: CaseIterable {
        case hero
        case catalog
        case petNotification
        case pets
    }

    enum SettingOption: CaseIterable {
        case account
        case blockUser
        case logout

        var title: String {
            switch self {
            case .account:
                return "帳戶設定"
            case .blockUser:
                return "黑名單管理"
            case .logout:
                return "登出"
            }
        }
        var icon: String {
            switch self {
            case .account:
                return "person.circle"
            case .blockUser:
                return "x.square.fill"
            case .logout:
                return "rectangle.portrait.and.arrow.right.fill"
            }
        }
    }

    enum CatalogSection: CaseIterable {

        case diary
        case supply
        case health

        var titleAndIcon: (title: String, icon: String) {
            switch self {
            case .diary:
                return ("相簿集", "diary")
            case .supply:
                return ("用品", "supply")
            case .health:
                return ("健康", "heart")
            }
        }

    }

    var user: User?
    let userName = Box("")
    let notifications = Box([Notification]())
    let notificationModels = Box([NotificationViewModel]())
    let pets = Box([Pet]())
    let usersPetsIds = Box([String]())
    var userDataDidLoad: (() -> Void)?
    var userNotificationsDidChange: (() -> Void)?
    var sections = Section.allCases
    var settingOptions = SettingOption.allCases
    var catalogSection = CatalogSection.allCases

    override init() {
        super.init()
        self.fetchUserData()
        self.listenNotificationData()
    }

    deinit {
        print("HomePageViewModel DIE")
    }

    func removeNotification(indexPath: Int) {

        let id = notifications.value[indexPath].id
        FirebaseManager.shared.removeNotification(notifyId: id)

    }

    func fetchUserData() {

        FirebaseManager.shared.fetchUserInfo { result in

            switch result {

            case .success(let user):

                self.user = user

                self.userName.value = user.userName

                self.usersPetsIds.value = user.petsIds ?? [String]()

                print("upDate UserData at HomeVM")

                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

                    let context = appDelegate.persistentContainer.viewContext
                    do {

                        let requests = try context.fetch(UserMO.fetchRequest())

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
                            let requests = try context.fetch(PetMO.fetchRequest())
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

            case .failure(let error):

                print("Can't Get Pets Data \(error)")

            }

        }
    }

    func coverToNotificationVM() {

        notificationModels.value = [NotificationViewModel]()
        self.notifications.value.forEach { notification in
            let viewModel = NotificationViewModel(notification: notification)
            notificationModels.value.append(viewModel)
        }

        self.userNotificationsDidChange?()
    }

    func listenNotificationData() {

        FirebaseManager.shared.listenNotifications { result in

            switch result {

            case .success(let notifications):

                var showNotifications = [Notification]()
                notifications.forEach { notification in
                    if notification.notifyTime.dateValue() < Date() {
                        showNotifications.append(notification)
                }
                }
                showNotifications = showNotifications.sorted(by: { $0.notifyTime.dateValue() > $1.notifyTime.dateValue()})
                self.notifications.value = showNotifications

                self.coverToNotificationVM()
                print("upDated NotificationData at HomeVM")

            case .failure(let error):

                print("Can't Get Notifications Data \(error)")

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

class NotificationViewModel {

    var content = Box("")
    var petId = Box("")
    var petPicUrl = Box("")
    var petName = Box("")
    var type = Box("")
    var diaryId = Box("")
    var supplyId = Box("")

    init(notification: Notification) {

        self.content.value = notification.content
        self.petId.value = notification.fromPets.first ?? ""
        self.type.value = notification.type
        FirebaseManager.shared.fetchPet(petId: self.petId.value) { result in
            switch result {

            case .success(let pet):
                self.petPicUrl.value = pet.petThumbnail?.url ?? ""
                self.petName.value = pet.name
            case .failure(let error):
                print(error)

            }
        }
        if let diaryId = notification.diaryId {
            self.diaryId.value = diaryId
        }

        if let supplyId = notification.supplyId {
            self.supplyId.value = supplyId
        }

    }
}
