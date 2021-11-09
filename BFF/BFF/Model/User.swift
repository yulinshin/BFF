//
//  User.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import Foundation

struct User: Codable {

    var userId: String
    var email: String
    var userName: String
    var blockPets: [String]?
    var petsIds: [String]?
    var userThumbNail: Pic?
    var followedPets: [String]?
    
}
