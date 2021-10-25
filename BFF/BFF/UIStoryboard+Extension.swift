//
//  UIStoryboard+Extension.swift
//  BFF
//
//  Created by yulin on 2021/10/24.
//

import UIKit

private struct StoryboardCategory {

    static let home = "Home"

    static let soical = "Soical"

    static let libary = "Libary"

    static let message = "Message"

    static let menu = "Menu"

    static let pet = "Pet"

    static let diary = "Diary"
}

extension UIStoryboard {

    static var home: UIStoryboard { return stStoryboard(name: StoryboardCategory.home) }

    static var soical: UIStoryboard { return stStoryboard(name: StoryboardCategory.soical) }

    static var libary: UIStoryboard { return stStoryboard(name: StoryboardCategory.libary) }

    static var message: UIStoryboard { return stStoryboard(name: StoryboardCategory.message) }

    static var menu: UIStoryboard { return stStoryboard(name: StoryboardCategory.menu) }

    static var pet: UIStoryboard { return stStoryboard(name: StoryboardCategory.pet) }

    static var diary: UIStoryboard { return stStoryboard(name: StoryboardCategory.diary) }

    private static func stStoryboard(name: String) -> UIStoryboard {

        return UIStoryboard(name: name, bundle: nil)
    }
}
