//
//  SupplyCellViewMdoel.swift
//  BFF
//
//  Created by yulin on 2021/10/25.
//

import Foundation
import UIKit
import SwiftUI

class SupplyViewModel {

// Data for View

    // swiftlint:disable:next line_length
    let deFultSupply = Supply(color: "123", cycleTime: "123", forPets: [String](), fullStock: 0, iconImage: "123", isReminder: true, perCycleTime: 0, reminderPercent: 0, stock: 0, supplyId: "123", supplyName: "123", unit: "123")

    let supplyIconImage = Box(" ")
    var iconColor = Box(" ")
    let supplyName = Box(" ")
    let inventoryStatusText = Box(" ")
    let inventoryStatusPercentage = Box(0.0)
    let maxInventory = Box(0)
    let reminingInventory = Box(0)
    let cycleDosage = Box(0)
    let supplyUseByPets = Box([String]())
    let isNeedToRemind = Box(true)
    let remindPercentage = Box(0.0)
    let supplyUnit = Box(" ")
    let cycleTime = Box(" ")

    init(from supply: Supply) {
        getSupplyData(from: supply)
    }


    init() {
        getSupplyData(from: deFultSupply)
    }


    func getSupplyData(from supply: Supply) {

        self.supplyIconImage.value = supply.iconImage
        self.supplyName.value = supply.supplyName
        let stockInMax = Double(supply.stock) / Double(supply.fullStock)
        self.inventoryStatusText.value = "\(stockInMax * 100)%"
        self.inventoryStatusPercentage.value = stockInMax
        self.maxInventory.value = supply.fullStock
        self.reminingInventory.value = supply.stock
        self.cycleDosage.value = supply.perCycleTime
        self.supplyUseByPets.value = supply.forPets
        self.isNeedToRemind.value = supply.isReminder
        self.remindPercentage.value = supply.reminderPercent
        self.supplyUnit.value = supply.unit
        self.cycleTime.value = supply.cycleTime
    }

}
