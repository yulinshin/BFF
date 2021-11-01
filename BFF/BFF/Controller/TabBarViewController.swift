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

        case .menu:
            controller = UINavigationController(rootViewController: UIStoryboard.menu.instantiateInitialViewController()!)
        }

        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {

        switch self {

        case .home:
            return UITabBarItem(
                title: "首頁",
                image: UIImage.asset(.MyPetsTab),
                selectedImage: UIImage.asset(.MyPetsTab)
            )

        case .soical:
            return UITabBarItem(
                title: "隨意逛",
                image: UIImage.asset(.Social),
                selectedImage: UIImage.asset(.Social)
            )

        case .libary:
            return UITabBarItem(
                title: "寵物圖書館",
                image: UIImage.asset(.LibaryTab),
                selectedImage: UIImage.asset(.LibaryTab)
            )

        case .message:
            return UITabBarItem(
                title: "私訊",
                image: UIImage.asset(.MessageTab),
                selectedImage: UIImage.asset(.MessageTab)
            )
        case .menu:
            return UITabBarItem(
                title: "更多",
                image: UIImage.asset(.MenuTab),
                selectedImage: UIImage.asset(.MenuTab)
            )

        }
    }
}

protocol MenuViewControllerDelegate {
    func didTapMenuButton()
}


class TabBarController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [ .soical, .message, .home, .libary]

    var showViewController = [UIViewController]()

    var menuDelegate: MenuViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor(named: "main")

        showViewController = tabs.map({ $0.controller() })

        viewControllers = showViewController

        self.selectedIndex = 2

        delegate = self

    }

    // MARK: - UITabBarControllerDelegate


    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

//        if viewController == showViewController[4] {
//
//            menuDelegate?.didTapMenuButton()
//
//            return false
//        }

      return true
    }


}
