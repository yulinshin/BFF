//
//  NavgationBar.swift
//  BFF
//
//  Created by yulin on 2021/11/25.
//

import Foundation
import UIKit

enum NavigationBarStyle {

    case transparentBackground
    case whiteBgWithMainColorTint
    var barAppearance: UINavigationBarAppearance {

        let barAppearance = UINavigationBarAppearance()

        switch self {
        case .transparentBackground:
            barAppearance.configureWithTransparentBackground()

        case .whiteBgWithMainColorTint:
            barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mainColor]
            barAppearance.backgroundColor = .white
        }

        return barAppearance
    }

}
