//
//  DiaryViewModel.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import Foundation
import Kingfisher

class SocialDiaryCellViewModel {
    var diary = Box(Diary())
    init(diary: Diary) {
        self.diary.value = diary
    }
}

class SocialDiaryWallViewModel {

    var petIds: [String]?
    var diaries = Box([Diary]())
    var showingDiaries = Box([SocialDiaryCellViewModel]())
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
                DispatchQueue.main.async {
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
                DispatchQueue.main.async {
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
                }

            case.failure(let error):

                print(error)

            }
        }
    }

    func updatePetData() {
        let group: DispatchGroup = DispatchGroup()
        var groupCount = 0
        var leaveGroupCount = 0
        for (index, diary) in diaries.value.enumerated() {
            group.enter()
            groupCount += 1
            print("group: enter \(groupCount) \(diary.petId)")
            FirebaseManager.shared.fetchPet(petId: diary.petId) { result in

                switch result {

                case.success(let pet):

                    self.diaries.value[index].petName = pet.name
                    self.diaries.value[index].petThumbnail = pet.petThumbnail ?? Pic(url: "", fileName: "")
                    group.leave()
                    leaveGroupCount += 1
                    print("group: leave \(leaveGroupCount)\(diary.petId)")

                case.failure(let error):
                    group.leave()
                    leaveGroupCount += 1
                    print("group:leave \(leaveGroupCount)\(diary.petId) ")
                        print(error)
                }

            }

        }

        group.notify(queue: DispatchQueue.main) {
            print("group: Notify")
            self.showingDiaries.value = self.diaries.value.map({SocialDiaryCellViewModel(diary: $0)})
            self.filterDiaries()
        }
    }

    func filterDiaries() {

        FirebaseManager.shared.fetchUserInfo { result in

            switch result {

            case.success( let user ):

                if let blockUsers = user.blockUsers {
                blockUsers.forEach({ userId in

                            self.showingDiaries.value = self.showingDiaries.value.filter { cellViewModel in
                                if cellViewModel.diary.value.userId == userId {
                                    return false
                                } else {
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

        var diary = self.showingDiaries.value[index].diary.value

        if diary.whoLiked.contains(FirebaseManager.shared.userId) {
            diary.whoLiked.removeAll { $0 == FirebaseManager.shared.userId }

            FirebaseManager.shared.upDateDiaryLiked(diaryId: diaries.value[index].diaryId, isLiked: false)

        } else {

            diary.whoLiked.append(FirebaseManager.shared.userId)
            FirebaseManager.shared.upDateDiaryLiked(diaryId: diaries.value[index].diaryId, isLiked: true)

        }
        self.showingDiaries.value[index].diary.value = diary
    }

    func blockUser(userId: String) {
        FirebaseManager.shared.updateBlockUser(blockUserId: userId)
        self.showingDiaries.value = self.showingDiaries.value.filter { viewModel in
            if viewModel.diary.value.userId == userId {
                return false
            } else {
                return true
            }
        }
        self.didUpDateData?()
    }
}
