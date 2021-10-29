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
    var userDataDidLoad: (() -> Void)?
    var userNotifiactionsDidChange: (() -> Void)?

    init() {
        self.fetchUserData()
        self.listenNotificationData()
    }

    deinit {
        print("HomePageViewModel DIE")
    }

    func fetchUserData() {

        FirebaseManager.shared.fetchUser { result in

            switch result {

            case .success(let user):

                self.userName.value = user.userName

                self.usersPetsIds.value = user.petsIds ?? [String]()

                print("upDate UserData at HomeVM")

                // save data to Local


                //

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

                // save data to Local


                //

            case .failure(let error):

                print("Can't Get Pets Data \(error)")

            }

        }
    }

    func listenNotificationData() {

        FirebaseManager.shared.listenNotifications { result in

            switch result {

            case .success(let notifications):

                self.notifiactions.value = notifications
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
