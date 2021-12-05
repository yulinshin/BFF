//
//  DiaryViewModel.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import Foundation

class SocialDiaryWallViewModel {

    var petIds: [String]?
    var diaries = Box([Diary]())
    var showingDiaries = Box([Diary]())
    var didUpDateData: (() -> Void)?
    var noMoreData: (() -> Void)?
    var getDataFailure: (() -> Void)?

    func fetchUserDiaries(isFetchMore: Bool = false) {

        if !isFetchMore {
            FirebaseManager.shared.userDiaryPagingLastDoc = nil
        }

        FirebaseManager.shared.fetchDiaries { result in

            switch result {

            case .success(let diaries):

                if  diaries.count == 0 {
                    self.noMoreData?() 
                } else {
                    if isFetchMore {
                        self.diaries.value += diaries
                    } else {
                        self.diaries.value = diaries
                    }

                    if let petIds = self.petIds {

                        self.diaries.value = self.diaries.value.filter({ diary in
                            if petIds.contains(diary.petId) {
                                return true
                            } else { return false }
                        })

                    }

                    self.updatePetData()
                }

            case.failure(let error):

                print(error)

            }
        }
    }

    func fetchPublicDiaries(isFetchMore: Bool = false) {

        if !isFetchMore {
            FirebaseManager.shared.publicDiaryPagingLastDoc = nil
        }

        FirebaseManager.shared.fetchPublicDiaries { result in

            switch result {

            case .success(let diaries):

                if  diaries.count == 0 {
                    self.noMoreData?()
                } else {
                    if isFetchMore {
                        self.diaries.value += diaries
                    } else {
                        self.diaries.value = diaries
                    }
                    self.updatePetData()
                }

            case.failure(let error):

                print(error)

            }
        }
    }

    func updatePetData() {
        let group: DispatchGroup = DispatchGroup()
        for (index, diary) in diaries.value.enumerated() {
            group.enter()
            print("group: enter")
            FirebaseManager.shared.fetchPet(petId: diary.petId) { result in

                switch result {

                case.success(let pet):

                    self.diaries.value[index].petname = pet.name
                    self.diaries.value[index].petThumbnail = pet.petThumbnail ?? Pic(url: "", fileName: "")
                    group.leave()
                    print("group: leave")

                case.failure(let error):
                    group.leave()
                    print("group:leave")
                        print(error)
                }

            }

        }

        group.notify(queue: DispatchQueue.main) {
            print("group: Notify")
            self.showingDiaries.value = self.diaries.value
            self.filterDiaries()
        }
    }

    func filterDiaries() {

        FirebaseManager.shared.fetchUserInfo { result in

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

                self.didUpDateData?()
            case.failure( let error ):

                print(error)
                self.didUpDateData?()
            }

        }

    }

    func updateWhoLiked(index: Int) {

        if diaries.value[index].whoLiked.contains(FirebaseManager.userId) {

            diaries.value[index].whoLiked.removeAll { $0 == FirebaseManager.userId }
              self.showingDiaries.value = self.diaries.value

            FirebaseManager.shared.upDateDiaryLiked(diaryId: diaries.value[index].diaryId, isLiked: false)

            self.didUpDateData?()

        } else {

            diaries.value[index].whoLiked.append(FirebaseManager.userId)
              self.showingDiaries.value = self.diaries.value
            FirebaseManager.shared.upDateDiaryLiked(diaryId: diaries.value[index].diaryId, isLiked: true)

            self.didUpDateData?()
        }
    }

    func blockUser(userId: String) {
        FirebaseManager.shared.updateBlockUser(blockUserId: userId)
        self.showingDiaries.value = self.showingDiaries.value.filter { diary in
            if diary.userId == userId {
                return false
            } else {
                return true
            }
        }
        self.didUpDateData?()
    }
}
