//
//  DiaryViewModel.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import Foundation

class DiaryWallViewModel {

    var diarys = Box([Diary]())
    var showingDiarys = Box([Diary]())
    var didupDateData: (()->Void)?

    func fetchDiary() {
        FirebaseManager.shared.fetchDiaries { result in


            switch result {

            case .success(let diarys):

                self.diarys.value = diarys
                self.showingDiarys.value = diarys
                self.didupDateData?()
            case .failure(let error):

                print(error)

            }
        }
    }

    func listenDiaries(){

        FirebaseManager.shared.listenDiaries { result in


            switch result {

            case .success(let diarys):

                self.diarys.value = diarys
                self.showingDiarys.value = diarys
                self.didupDateData?()
            case .failure(let error):

                print(error)

            }
        }
    }

    func fielter(petIds:[String]) {

        showingDiarys.value = diarys.value.filter({ diary in
            if petIds.contains(diary.petId) {
                return true
            } else { return false }
        })
    }

    func updateWhoLiked(index: Int){

        if diarys.value[index].whoLiked.contains(FirebaseManager.shared.userId) {

            FirebaseManager.shared.upDateDiaryLiked(diaryId: diarys.value[index].diaryId, isLiked: false)

          diarys.value[index].whoLiked.removeAll { $0 != FirebaseManager.shared.userId }
            self.didupDateData?()

        } else {

            FirebaseManager.shared.upDateDiaryLiked(diaryId: diarys.value[index].diaryId, isLiked: true)
          diarys.value[index].whoLiked.append(FirebaseManager.shared.userId)
            self.didupDateData?()
        }
    }
}
