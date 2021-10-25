//
//  File.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import Foundation
import FirebaseFirestore

struct Goal: Codable {

    var createdTime: Timestamp
    var goalName: String
    var image: String

}
