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

    let supplyIconImage = Box("")
    let iconColor = Box("")
    let supplyName = Box("")
    let inventoryStatusText = Box("")
    let inventoryStatusPercentage = Box(0.0)
    let maxInventory = Box(0)
    let reminingInventory = Box(0)
    let cycleDosage = Box(0)
    let supplyUseByPets = Box([String]())
    let isNeedToRemind = Box(true)
    let remindPercentage = Box(0.0)
    let suppluUnit = Box("")

    init(from supply: Supply) {
        getSupplyData(from: supply)
    }

    func getSupplyData(from supply: Supply) {

        self.supplyIconImage.value = supply.iconImage
        self.supplyName.value = supply.supplyName
        let stockInMax = Double(supply.stock / supply.fullStock)
        self.inventoryStatusText.value = "\(stockInMax * 100)%"
        self.inventoryStatusPercentage.value = stockInMax
        self.maxInventory.value = supply.fullStock
        self.reminingInventory.value = supply.stock
        self.cycleDosage.value = supply.perCycleTime
        self.supplyUseByPets.value = supply.forPets
        self.isNeedToRemind.value = supply.isReminder
        self.remindPercentage.value = supply.reminderPercent
        self.suppluUnit.value = supply.unit

    }

}
