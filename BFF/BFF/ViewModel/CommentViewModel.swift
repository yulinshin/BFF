//
//  CommentViewModel.swift
//  BFF
//
//  Created by yulin on 2021/11/6.
//

import Foundation
import Kingfisher
import AVFoundation

class CommentViewModel {

    let name = Box(" ")
    let pic = Box(" ")
    let content = Box(" ")
    let date = Box(" ")
    let creatTime = Box(Date())
    var didGetPetInfo: (() -> Void)?

    init(from comment: Comment, updateNotify: @escaping (()->Void)) {
        self.didGetPetInfo = updateNotify
        getCommentData(from: comment)
    }
    func getCommentData(from comment: Comment) {

        creatTime.value = comment.createdTime.dateValue()

        FirebaseManager.shared.fetchPet(petId: comment.petId) { result in

            switch result {

            case .success(let pet):

                self.name.value = pet.name
                self.pic.value = pet.petThumbnail?.url ?? ""
                self.didGetPetInfo?()

            case .failure(let error):
                print(error)


            }


        }

        self.content.value = comment.content
        self.date.value = comment.createdTime.dateValue().toString()

    }

}
