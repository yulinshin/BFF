//
//  Date+Extension.swift
//  BFF
//
//  Created by yulin on 2021/11/1.
//

import Foundation

extension Date {

    func daysBetweenDate(toDate: Date) -> Int {

        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0

    }

    func toString() -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm"
        return dateFormatter.string(from: self)

    }

    func getAge(from strData: String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        guard let date = dateFormatter.date(from: strData) else { return ""}
        let now = Date()

        let ageComponents = Calendar.current.dateComponents([.year, .month], from: date, to: now)

        var birthday = ""
        if let age = ageComponents.year {
            if let month = ageComponents.month {
                birthday = "\(age)歲\(month)個月"
            } else {
                birthday = "\(age)歲"
            }
        } else {
            if let month = ageComponents.month {
                birthday = "\(month)個月"
            } else {

                birthday = "0個月"
                }
            }

        return birthday
    }

}
