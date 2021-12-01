//
//  BFFTests.swift
//  BFFTests
//
//  Created by yulin on 2021/11/25.
//

import XCTest
@testable import BFF

class BFFTests: XCTestCase {

    var notificationMangerTest: NotificationManger!
    var petCollectionViewCellTest: PetCollectionViewCell!

    override func setUpWithError() throws {
        try super.setUpWithError()
        notificationMangerTest = NotificationManger()
        petCollectionViewCellTest = PetCollectionViewCell()

    }

    override func tearDownWithError() throws {
        notificationMangerTest = nil
        petCollectionViewCellTest = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testCountNotifyDateNomal() {

        let fullStock = 100
        let stock = 50
        let reminderPercent = 20.0
        let perCycleTime = 10
        let cycleTime = "每日"
        let testFromDateStr = "1991-01-01 13:22:22"
        let ansDateStr = "1991-01-04 13:22:22"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fromDate = formatter.date(from: testFromDateStr)!
        let ansDate = formatter.date(from: ansDateStr)!

        let result = notificationMangerTest.countNotifyDate(fullStock: fullStock, stock: stock, reminderPercent: reminderPercent, perCycleTime: perCycleTime, cycleTime: cycleTime, fromDate: fromDate)

        XCTAssertEqual(result, ansDate, "Count Notify Date is wrong:\(result)")

    }

    func testCountNotifyDateTightStock() {

        let fullStock = 100
        let stock = 10
        let reminderPercent = 20.0
        let perCycleTime = 10
        let cycleTime = "每日"
        let testFromDateStr = "1991-01-01 13:22:00"
        let ansDateStr = "1991-01-01 13:22:10"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fromDate = formatter.date(from: testFromDateStr)!
        let ansDate = formatter.date(from: ansDateStr)

        let result = notificationMangerTest.countNotifyDate(fullStock: fullStock, stock: stock, reminderPercent: reminderPercent, perCycleTime: perCycleTime, cycleTime: cycleTime, fromDate: fromDate)

        XCTAssertEqual(result, ansDate, "Count Notify Date is wrong:\(result)")

    }

    func testCountNotifyDateOutOfStock() {

        let fullStock = 100
        let stock = 8
        let reminderPercent = 20.0
        let perCycleTime = 10
        let cycleTime = "每日"
        let testFromDateStr = "1991-01-01 13:22:00"
        let ansDateStr = "1991-01-01 13:22:10"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fromDate = formatter.date(from: testFromDateStr)!
        let ansDate = formatter.date(from: ansDateStr)

        let result = notificationMangerTest.countNotifyDate(fullStock: fullStock, stock: stock, reminderPercent: reminderPercent, perCycleTime: perCycleTime, cycleTime: cycleTime, fromDate: fromDate)

        XCTAssertEqual(result, ansDate, "Count Notify Date is wrong:\(result)")

    }

    func testCountNotifyDateShortage() {

        let fullStock = 100
        let stock = -10
        let reminderPercent = 20.0
        let perCycleTime = 10
        let cycleTime = "每日"
        let testFromDateStr = "1991-01-01 13:22:00"
        let ansDateStr = "1991-01-01 13:22:10"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fromDate = formatter.date(from: testFromDateStr)!
        let ansDate = formatter.date(from: ansDateStr)

        let result = notificationMangerTest.countNotifyDate(fullStock: fullStock, stock: stock, reminderPercent: reminderPercent, perCycleTime: perCycleTime, cycleTime: cycleTime, fromDate: fromDate)

        XCTAssertEqual(result, ansDate, "Count Notify Date is wrong:\(result)")

    }

    func testCalculateBirthdayNow() {

        let petBirthday = "Nov 26, 2021"

        let result = petCollectionViewCellTest.calculateBirthday(petBirthday: petBirthday)

        XCTAssertEqual(result, "0個月", "Count Notify Date is wrong:\(result)")

    }

    func testCalculateBirthdayOneMouth() {

        let petBirthday = "Oct 26, 2021"

        let result = petCollectionViewCellTest.calculateBirthday(petBirthday: petBirthday)

        XCTAssertEqual(result, "1個月", "Count Notify Date is wrong:\(result)")

    }

    func testCalculateBirthdayOneYearOneMonth() {

        let petBirthday = "Oct 26, 2020"

        let result = petCollectionViewCellTest.calculateBirthday(petBirthday: petBirthday)

        XCTAssertEqual(result, "1歲1個月", "Count Notify Date is wrong:\(result)")

    }

    func testCalculateBirthdayMinus() {

        let petBirthday = "Oct 26, 2023"

        let result = petCollectionViewCellTest.calculateBirthday(petBirthday: petBirthday)

        XCTAssertEqual(result, "0個月", "Count Notify Date is wrong:\(result)")

    }

}
