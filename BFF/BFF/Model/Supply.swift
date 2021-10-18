//
//  Supply.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import Foundation

struct Supply: Codable {

    var color: String
    var cycleTime: String
    var forPets: [String]
    var fullStock: Double
    var iconImage: String
    var isReminder: Bool
    var perCycleTime: Double
    var reminderPercent: Double
    var stock: Double
    var supplyID: String
    var supplyName: String
    var unit: String
    
}
