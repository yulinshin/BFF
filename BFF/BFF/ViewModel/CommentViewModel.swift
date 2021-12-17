//
//  CommentViewModel.swift
//  BFF
//
//  Created by yulin on 2021/11/6.
//

import Foundation
import Kingfisher
import AVFoundation

class CommentModels {
    var diary: Diary
    var data = [Comment]()
    var viewModels = Box([CommentViewModel]())
    var didUpdateData: (() -> Void)?
    init(diary: Diary) {
        self.diary = diary
        self.getComments()
    }

    func getComments() {

        self.viewModels.value.removeAll()
        let firstChat = Comment(commentId: "", content: diary.content, createdTime: diary.createdTime, diaryId: diary.diaryId, petId: diary.petId)

        let chatViewModel = CommentViewModel(from: firstChat)
        self.viewModels.value.append(chatViewModel)

        FirebaseManager.shared.fetchComments(diaryId: diary.diaryId) { result in
            switch result {

            case .success(let comments):

                self.data = comments

                self.filterBlockUser()

            case .failure(let error):
                print(error)

            }
        }
    }

    private func filterBlockUser() {

        let group = DispatchGroup()

        data.forEach { comment in
            group.enter()
            FirebaseManager.shared.fetchPet(petId: comment.petId) { result in
                switch result {

                case .success(let pet):
                    guard let blockUsers = FirebaseManager.shared.currentUser?.blockUsers else {
                        let chatViewModel = CommentViewModel(from: comment)
                        self.viewModels.value.append(chatViewModel)
                        group.leave()
                        return
                    }

                    if !blockUsers.contains(pet.userId) {
                        let chatViewModel = CommentViewModel(from: comment)
                        self.viewModels.value.append(chatViewModel)
                        group.leave()
                    }

                case .failure(let error):
                    print(error)

                }

            }
        }

        group.notify(queue: DispatchQueue.main) {
            self.sortViewModel()
        }
    }

    private func sortViewModel() {
        self.viewModels.value = self.viewModels.value.sorted { first, second in
            first.createTime.value < second.createTime.value
        }
        didUpdateData?()
    }

    func createComment(message: String, petId: String) {

        FirebaseManager.shared.createComment(content: message, petId: petId, diaryId: diary.diaryId, diaryOwner: diary.userId) { result in
            switch result {
            case .success:
                print("Send Comments Success")
                self.getComments()

            case.failure(let error):
                print("Send Comments Failure: \(error)")
            }

        }
    }
}

class CommentViewModel {

    let name = Box(" ")
    let pic = Box(" ")
    let content = Box(" ")
    let date = Box(" ")
    let createTime = Box(Date())
    var didGetPetInfo: (() -> Void)?

    init(from comment: Comment) {
        getCommentData(from: comment)
    }
    func getCommentData(from comment: Comment) {

        createTime.value = comment.createdTime.dateValue()

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
