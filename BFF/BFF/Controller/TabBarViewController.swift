//
//  TabBarViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/24.
//

import UIKit

private enum Tab {

    case home

    case soical

    case libary

    case message

    case menu

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .home: controller = UIStoryboard.home.instantiateInitialViewController()!

        case .soical: controller = UIStoryboard.soical.instantiateInitialViewController()!

        case .libary: controller = UIStoryboard.libary.instantiateInitialViewController()!

        case .message: controller = UIStoryboard.message.instantiateInitialViewController()!

        case .menu: controller = UIStoryboard.menu.instantiateInitialViewController()!

        }

        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {

        switch self {

        case .home:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.MyPetsTab),
                selectedImage: UIImage.asset(.MyPetsTab)
            )

        case .soical:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Social),
                selectedImage: UIImage.asset(.Social)
            )

        case .libary:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.LibaryTab),
                selectedImage: UIImage.asset(.LibaryTab)
            )

        case .message:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.MessageTab),
                selectedImage: UIImage.asset(.MessageTab)
            )
        case .menu:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.MenuTab),
                selectedImage: UIImage.asset(.MenuTab)
            )
            
        }
    }
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [ .soical, .message, .home, .libary, .menu]

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map({ $0.controller() })
        self.selectedIndex = 2

        delegate = self
    }

    // MARK: - UITabBarControllerDelegate

}
