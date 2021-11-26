//
//  SupplyCellViewMdoel.swift
//  BFF
//
//  Created by yulin on 2021/10/25.
//

import Foundation
import UIKit
import Kingfisher
import Firebase

class SupplyViewModel {

// Data for View

    // swiftlint:disable:next line_length
    let deFultSupply = Supply(color: "red", cycleTime: " ", forPets: [String](), fullStock: 0, iconImage: "bag", isReminder: true, perCycleTime: 0, reminderPercent: 0, stock: 0, supplyId: " ", supplyName: " ", unit: " ", lastUpdate: Timestamp.init(date: Date()))

    var supply: Supply?

    let supplyIconImage = Box(" ")
    var iconColor = Box(" ")
    let supplyName = Box(" ")
    let inventoryStatusText = Box(" ")
    let inventoryStatusPercentage = Box(0.0)
    let maxInventory = Box(0)
    let remainingInventory = Box(0)
    let cycleDosage = Box(0)
    let supplyUseByPets = Box([String]())
    let isNeedToRemind = Box(true)
    let remindPercentage = Box(0.0)
    let supplyUnit = Box(" ")
    let cycleTime = Box(" ")
    let imageUrl = Box([String]())
    let supplyId = Box(" ")
    let updateTime = Box(Timestamp())

    init(from supply: Supply) {
        getSupplyData(from: supply)
    }

    init() {

    }

    func getSupplyData(from supply: Supply) {
        self.supplyId.value = supply.supplyId
        self.supplyIconImage.value = supply.iconImage
        self.iconColor.value = supply.color
        self.supplyName.value = supply.supplyName
        self.maxInventory.value = supply.fullStock
        self.remainingInventory.value = supply.stock
        self.cycleDosage.value = supply.perCycleTime
        self.supplyUseByPets.value = supply.forPets
        self.isNeedToRemind.value = supply.isReminder
        self.remindPercentage.value = supply.reminderPercent
        self.supplyUnit.value = supply.unit
        self.cycleTime.value = supply.cycleTime
        self.supply = supply
        self.calculateInventoryStatus()
    }

    func updateToDataBase() {
        // swiftlint:disable:next line_length
        let supply = Supply(color: self.iconColor.value, cycleTime: self.cycleTime.value, forPets: self.supplyUseByPets.value, fullStock: self.maxInventory.value, iconImage: self.supplyIconImage.value, isReminder: self.isNeedToRemind.value, perCycleTime: self.cycleDosage.value, reminderPercent: self.remindPercentage.value, stock: self.remainingInventory.value, supplyId: self.supplyId.value, supplyName: self.supplyName.value, unit: self.supplyUnit.value, lastUpdate: Timestamp.init(date: Date()))

        FirebaseManager.shared.updateSupply(supplyId: supply.supplyId, data: supply)
        calculateInventoryStatus()
    }

    func calculateInventoryStatus() {
        let stockInMax = Double(remainingInventory.value) / Double(maxInventory.value)
        if stockInMax.isNaN || stockInMax.isInfinite {
           self.inventoryStatusText.value = "\(stockInMax)"
       } else {
           self.inventoryStatusText.value = "\(Int(stockInMax * 100))%"
       }
       self.inventoryStatusPercentage.value = stockInMax
    }

    func deleteSuppliesData() {

        print("Start fetch supplies data")

        FirebaseManager.shared.delateSupply(supplyId: self.supplyId.value) { result in

            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print(error)
            }
        }
    }

    func packSupply() -> Supply {
        // swiftlint:disable:next line_length
        let supply = Supply(color: self.iconColor.value, cycleTime: self.cycleTime.value, forPets: self.supplyUseByPets.value, fullStock: self.maxInventory.value, iconImage: self.supplyIconImage.value, isReminder: self.isNeedToRemind.value, perCycleTime: self.cycleDosage.value, reminderPercent: self.remindPercentage.value, stock: self.remainingInventory.value, supplyId: self.supplyId.value, supplyName: self.supplyName.value, unit: self.supplyUnit.value, lastUpdate: self.updateTime.value)
        return supply
    }

}
