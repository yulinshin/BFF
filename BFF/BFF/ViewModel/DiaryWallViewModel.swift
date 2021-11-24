//
//  DiaryViewModel.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import Foundation

class DiaryWallViewModel {

    var diaries = Box([Diary]())
    var showingDiaries = Box([Diary]())
    var didUpDateData: (() -> Void)?
    var getDataFailure: (() -> Void)?

    func fetchDiary() {
        FirebaseManager.shared.fetchDiaries { result in

            switch result {

            case .success(let diaries):

                if diaries.count == 0 {
                    self.getDataFailure

                } else {

                self.diaries.value = diaries
                self.showingDiaries.value = diaries
                self.updatePetData()

                }

            case.failure(let error):

                self.getDataFailure

                print(error)

            }
        }
    }

    func fetchAllDiary() {
        FirebaseManager.shared.fetchAllDiaries { result in

            switch result {

            case .success(let diaries):

                if  diaries.count == 0 {

                    self.getDataFailure

                } else {

                self.diaries.value = diaries
                self.updatePetData()

                }

            case.failure(let error):

                print(error)
                self.getDataFailure

            }
        }
    }

    func updatePetData() {

        for (index, diary) in diaries.value.enumerated() {

            FirebaseManager.shared.fetchPet(petId: diary.petId) { result in

                switch result {

                case.success(let pet):

                    self.diaries.value[index].petname = pet.name
                    self.diaries.value[index].petThumbnail = pet.petThumbnail ?? Pic(url: "", fileName: "")
                    self.showingDiaries.value = self.diaries.value
                    self.filterDiaries()


                case.failure(let error):

                        print(error)
                }

            }

        }
    }

    func filterDiaries() {


        FirebaseManager.shared.fetchCurrentUserInfo { result in

            switch result {

            case.success( let user ):

                if let blockUsers = user.blockUsers {
                blockUsers.forEach({ userId in

                            self.showingDiaries.value = self.showingDiaries.value.filter { diary in
                                if diary.userId == userId {
                                    print(self.showingDiaries.value.count)
                                    return false
                                } else {
                                    print(self.showingDiaries.value.count)
                                    return true
                                }
                            }
                }) } else {
                    self.didUpDateData?()
                }


                print("*** showingDiaries: \(self.showingDiaries.value.count)")
                self.didUpDateData?()
            case.failure( let error ):

                print(error)
                self.didUpDateData?()
            }

        }

    }

    func listenDiaries() {

        FirebaseManager.shared.listenDiaries { result in

            switch result {

            case .success(let diaries):

                self.diaries.value = diaries
                self.showingDiaries.value = diaries
                self.didUpDateData?()
            case .failure(let error):

                print(error)

            }
        }
    }

    func filter(petIds: [String]) {

        showingDiaries.value = diaries.value.filter({ diary in
            if petIds.contains(diary.petId) {
                return true
            } else { return false }
        })
    }

    func updateWhoLiked(index: Int) {

        if diaries.value[index].whoLiked.contains(FirebaseManager.shared.userId) {

            diaries.value[index].whoLiked.removeAll { $0 == FirebaseManager.shared.userId }
              self.showingDiaries.value = self.diaries.value

            FirebaseManager.shared.upDateDiaryLiked(diaryId: diaries.value[index].diaryId, isLiked: false)

            self.didUpDateData?()

        } else {

            diaries.value[index].whoLiked.append(FirebaseManager.shared.userId)
              self.showingDiaries.value = self.diaries.value
            FirebaseManager.shared.upDateDiaryLiked(diaryId: diaries.value[index].diaryId, isLiked: true)

            self.didUpDateData?()
        }
    }
}
