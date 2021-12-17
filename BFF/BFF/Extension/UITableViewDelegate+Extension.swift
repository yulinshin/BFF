//
//  UITableViewDelegate+Extension.swift
//  BFF
//
//  Created by yulin on 2021/12/17.
//

import Foundation
import UIKit

enum TableViewIndexPathError: Error {
    case outOfRange
}

extension UITableViewDelegate {

    func checkIndexPathRange(dataRange: Int, indexPath: IndexPath) throws {

        if dataRange < indexPath.row {
            print("indexPath Out Of Range")
            throw TableViewIndexPathError.outOfRange
        }

    }

}
