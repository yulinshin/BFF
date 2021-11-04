//
//  Diary.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import Foundation
import FirebaseFirestore
import UIKit

struct Diary: Codable {

    var comments: [String]
    var content: String
    var createdTime: Timestamp
    var diaryId: String
    var images: [Pic]
    var isPublic: Bool
    var petTags: [String]
    var whoLiked: [String] = [String]()
    var userId: String
    var petId: String

    init(
    content: String,
    diaryId: String,
    images: [Pic],
    isPublic: Bool,
    petTags: [String],
    userId: String,
    petId: String
    ) {
        self.comments = [String]()
        self.content = content
        self.createdTime = Timestamp.init(date: Date())
        self.diaryId = diaryId
        self.images = images
        self.isPublic = isPublic
        self.petTags =  petTags
        self.userId = userId
        self.petId = petId
    }

}
