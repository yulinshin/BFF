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

    func fetchDiary(){
        FirebaseManager.shared.fetchDiaries { result in


            switch result {

            case .success(let diarys):

                self.diarys.value = diarys
                self.showingDiarys.value = diarys

            case .failure(let error):

                print(error)

            }
        }
    }

    func fielter(petIds:[String]){

        showingDiarys.value = diarys.value.filter({ diary in
            if petIds.contains(diary.petId){
                return true
            } else { return false }
        })
    }

}
