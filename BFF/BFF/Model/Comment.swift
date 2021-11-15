//
//  Comment.swift
//  BFF
//
//  Created by yulin on 2021/11/6.
//

import Foundation
import Firebase

struct Comment: Codable {

    var commentId: String
    var content: String
    var createdTime: Timestamp
    var diaryId: String
    var petId: String

}
