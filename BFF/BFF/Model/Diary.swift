//
//  Diary.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import Foundation
import FirebaseFirestore

struct Diary: Codable {

    var comments: [String]
    var content: String
//    var createdTime: Timestamp
    var diaryId: String
    var images: [String]
    var isPublic: Bool
    var petTags: [String]

}
