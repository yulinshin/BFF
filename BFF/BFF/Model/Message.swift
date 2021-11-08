//
//  Message.swift
//  BFF
//
//  Created by yulin on 2021/11/6.
//

import Foundation
import Firebase

struct Message: Codable {

    var content: String
    var createdTime: Timestamp
    var receiver: String
    var sender: String
    var messageId: String

}
