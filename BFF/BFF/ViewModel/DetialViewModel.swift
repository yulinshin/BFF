//
//  DetialViewModel.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import Foundation
import UIKit
import Kingfisher
import FirebaseFirestoreSwift

class DetialViewModel {

    private static let defaultDiray = Diary(content: " ", diaryId: " ", images: [Pic](), isPublic: true, petTags: [String](), userId: " ", petId: " ")
    let postImageUrl = Box(" ")
    let postPetsName = Box(" ")
    let postPetImageUrl = Box(" ")
    let postPetFileName = Box(" ")
    let creatDate = Box(" ")
    let contentText = Box(" ")
    let petTags = Box([String]())
    let numberOfComments = Box(0)
    let comments = Box([String]())
    let isPublic = Box(false)
    let diaryId = Box(" ")

    init() {
        getdiaryData(from: Self.defaultDiray)
    }

    init(from diary: Diary) {
        getdiaryData(from: diary)
    }

    private func getdiaryData(from diary: Diary) {
        if let image = diary.images.first {
            self.postPetImageUrl.value = image.url
            self.postPetFileName.value = image.fileName
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        let date = diary.createdTime.dateValue()
        self.creatDate.value = dateFormatter.string(from: date)
        self.contentText.value = diary.content
        self.petTags.value = diary.petTags
        self.numberOfComments.value = diary.comments.count
        self.comments.value = diary.comments
        self.isPublic.value = diary.isPublic
        self.diaryId.value = diary.diaryId
        FirebaseManager.shared.fetchPet(petId: diary.petId) { result in
            switch result {
            case .success(let pet):
                self.postPetsName.value = pet.name
            case .failure(let error):
                print("fetchData.failure\(error)")
                self.postPetsName.value = ""
                self.postPetImageUrl.value = ""
            }
        }
    }

    func changePrivacy(isPublic: Bool) {
        self.isPublic.value = isPublic
        FirebaseManager.shared.updateDiaryPrivacy(diaryId: diaryId.value, isPublic: isPublic)
    }

    func updateDiary(content: String) {
        self.contentText.value = content
        FirebaseManager.shared.updateDiaryContent(diaryId: diaryId.value, content: content)
    }

    func deleteDiary(){
        var pic = Pic(url: postImageUrl.value, fileName: postPetFileName.value)
        print("Delete\(pic)")
        FirebaseManager.shared.delateDiary(diaryId: diaryId.value, diatyPics:[pic]) { result in
            switch result {
            case .success(let sucessMessage):
                print(sucessMessage)

            case .failure(let error):
                print("fetchData.failure\(error)")
            }
        }
    }
}

