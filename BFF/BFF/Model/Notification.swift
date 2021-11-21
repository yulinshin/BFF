//
//  Notification.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import Foundation
import FirebaseFirestore

struct Notification: Codable {

    var content: String
    var notifyTime: Timestamp
    var fromPets: [String]
    var title: String
    var type: String
    var id: String
    var diaryId: String?
    var supplyId: String?

}
