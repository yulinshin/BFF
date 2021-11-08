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

    func fetchDiary() {
        FirebaseManager.shared.fetchDiaries() { result in

            switch result {

            case .success(let diaries):

                self.diaries.value = diaries
                self.showingDiaries.value = diaries
                self.updatePetData()

            case.failure(let error):

                print(error)

            }
        }
    }


    func fetchAllDiary() {
        FirebaseManager.shared.fetchAllDiaries() { result in

            switch result {

            case .success(let diaries):

                self.diaries.value = diaries
                self.showingDiaries.value = diaries
                self.updatePetData()

            case.failure(let error):

                print(error)

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
                    self.didUpDateData?()

                case.failure(let error):

                        print(error)
                }

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

    func fielter(petIds: [String]) {

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
