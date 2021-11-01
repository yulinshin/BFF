//
//  UIImage+Extension.swift
//  BFF
//
//  Created by yulin on 2021/10/24.
//

import UIKit

enum ImageAsset: String {

    // Profile tab - Tab

    // swiftlint:disable identifier_name
    case LibaryTab
    case MenuTab
    case MessageTab
    case MyPetsTab
    case Social

}

// swiftlint:enable identifier_name

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }
}
