//
//  Date+Extension.swift
//  BFF
//
//  Created by yulin on 2021/11/1.
//

import Foundation

extension Date {

    func daysBetweenDate(toDate:Date) -> Int {

        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0

    }

    func toString() -> String{

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm"
        return dateFormatter.string(from: self)

    }


}
