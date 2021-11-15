//
//  Pet.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import Foundation
import FirebaseFirestore

struct Pet: Codable {

    var petId: String
    var name: String
    var userId: String
    var healthInfo: HealthInfo
    var medicalRecords: [MedicalRecord]?
    var petThumbnail: Pic?
    var followers: [String]?
    var liked: Int?
}

struct Pic: Codable {
    var url: String
    var fileName: String
}

struct HealthInfo: Codable {

    var birthday: String
    var chipId: String
    var gender: String
    var note: String
    var type: String
    var weight: Double
    var weightUnit: String

}

struct MedicalRecord: Codable {

    var images: [String]
    var note: String
    var time: Timestamp

}
