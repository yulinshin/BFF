//
//  DetialViewModel.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import Foundation
import UIKit
import Kingfisher

class DetialViewModel {

    private static let defaultDiray = Diary(content: " ", diaryId: " ", images: [String](), isPublic: true, petTags: [String](), userId: " ", petId: " ")
    let postImageUrl = Box(" ")
    let postPetsName = Box(" ")
    let postPetImageUrl = Box(" ")
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

    init(from diary: Diary){
        getdiaryData(from: diary)
    }

    private func getdiaryData(from diary: Diary){
        if let image = diary.images.first{
            self.postPetImageUrl.value = image
        }
        self.creatDate.value = diary.createdTime.dateValue().ISO8601Format()
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
                self.postPetImageUrl.value = pet.petThumbnail
            case .failure(let error):
                print("fetchData.failure\(error)")
                self.postPetsName.value = ""
                self.postPetImageUrl.value = ""
            }
        }
    }

    func changePrivacy(isPublic: Bool) {
        self.isPublic.value = isPublic
        FirebaseManager.shared.updateDiaryPrivacy(diaryId:diaryId.value , isPublic: isPublic)
    }
}
