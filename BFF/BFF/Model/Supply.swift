//
//  Supply.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import Foundation
import Firebase

struct Supply: Codable {

    var color: String
    var cycleTime: String
    var forPets: [String]
    var fullStock: Int
    var iconImage: String
    var isReminder: Bool
    var perCycleTime: Int
    var reminderPercent: Double
    var stock: Int
    var supplyId: String
    var supplyName: String
    var unit: String
    var lastUpdate: Timestamp

    mutating func calculateSupplyInventory() {

        let daysBetweenDate = self.lastUpdate.dateValue().daysBetweenDate(toDate: Date())
        if daysBetweenDate > 0 {
            let consume = self.perCycleTime * daysBetweenDate
            let newStock = self.stock - consume
            self.stock = newStock
            FirebaseManager.shared.updateSupply(supplyId: self.supplyId, data: self)
            if self.isReminder == true {
                NotificationManger.shared.createSupplyNotification(supply: self)
            }
        }
    }
    
}
