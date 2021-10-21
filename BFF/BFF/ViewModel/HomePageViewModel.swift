//
//  HomePageView.swift
//  BFF
//
//  Created by yulin on 2021/10/21.
//

import Foundation

class HomePageViewModel {

    let userName = Box("")
    let notifiactions = Box([Notification]())
    let pets = Box([Pet]())
    let usersPetsIds = Box([String]())

    init() {
        self.listenUsersPets()
        self.listenUserData()
        self.listenNotificationData()
    }

    func listenUserData() {

        FirebaseManager.shared.listenUser { result in

            switch result {

            case .success(let user):

                self.userName.value = user.userName

                self.usersPetsIds.value = user.petsIds ?? [String]()

            case .failure(let error):

                print("Can't Get User Info \(error)")

            }

        }

    }

    func listenNotificationData() {

        FirebaseManager.shared.listenNotifications { result in

            switch result {

            case .success(let notifications):

                self.notifiactions.value = notifications

            case .failure(let error):

                print("Can't Get Notifications Data \(error)")

            }

        }

    }

    func listenUsersPets() {

        FirebaseManager.shared.listenUsersPets { result in

            switch result {

            case .success(let pets):

                self.pets.value = pets

            case .failure(let error):

                print("Can't Get Pets Data \(error)")

            }

        }

    }
}
