//
//  TabBarViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/24.
//

import UIKit

private enum Tab {

    case home

    case social

    case library

    case message

    case midle

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .home: controller = UIStoryboard.home.instantiateInitialViewController()!

        case .social: controller = UIStoryboard.social.instantiateInitialViewController()!

        case .library: controller = UIStoryboard.library.instantiateInitialViewController()!

        case .midle: controller = UIViewController()

        case .message:
            let storyboard = UIStoryboard.message
            if let chatController = storyboard.instantiateViewController(withIdentifier: "ChatListTableViewController") as? ChatListTableViewController {
                chatController.viewModel = ChatListViewModel(updateNotify: {
                    chatController.tableView?.reloadData()
            })
                let nav = UINavigationController(rootViewController: chatController)
                controller = nav
            } else {
                controller = UIViewController()
            }
    }
        controller.tabBarItem = tabBarItem()
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 0.5, left: 0, bottom: 0.5, right: 0)
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

        case .social:
            return UITabBarItem(
                title: "隨意逛",
                image: UIImage.asset(.Social),
                selectedImage: UIImage.asset(.Social)
            )

        case .library:
            return UITabBarItem(
                title: "寵物地圖",
                image: UIImage.asset(.LibraryTab),
                selectedImage: UIImage.asset(.LibraryTab)
            )

        case .message:
            return UITabBarItem(
                title: "私訊",
                image: UIImage.asset(.MessageTab),
                selectedImage: UIImage.asset(.MessageTab)
            )
        case .midle:
            return UITabBarItem(
                title: "新增日記",
                image: UIImage(),
                selectedImage: UIImage()
            )

        }
    }
}


class TabBarController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [  .home,.social, .midle, .message, .library]

    var showViewController = [UIViewController]()
    let actionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor(named: "main")

        let appearance = tabBar.standardAppearance
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundColor = .white
        tabBar.standardAppearance = appearance

        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 4
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1

        showViewController = tabs.map({ $0.controller() })

        viewControllers = showViewController

        self.selectedIndex = 0

        delegate = self

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupMiddleButton()
    }


    // MARK: - UITabBarControllerDelegate


    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if viewController == showViewController[2] {
            return false
        }

        viewController.navigationController?.popToViewController(viewController, animated: true)

      return true
    }

    func setupMiddleButton() {

        var actionButtonFrame = actionButton.frame
        actionButtonFrame.origin.x = tabBar.bounds.width/2 - actionButtonFrame.size.width/2
        actionButtonFrame.origin.y = -actionButtonFrame.size.height/2
        actionButton.frame = actionButtonFrame
        actionButton.backgroundColor = UIColor(named: "main")
        actionButton.setImage(UIImage(systemName: "plus"), for: .normal)
        actionButton.tintColor = .white
        actionButton.layer.cornerRadius = actionButtonFrame.height/2
        tabBar.addSubview(actionButton)
        actionButton.addTarget(self, action: #selector(actionButtonAction(sender:)), for: .touchUpInside)

        view.layoutIfNeeded()
    }



    @objc private func actionButtonAction(sender: UIButton) {

       let storyboard = UIStoryboard(name: "Diary", bundle: nil)
       guard let controller = storyboard.instantiateViewController(withIdentifier: "CreatDiaryViewController") as? CreatDiaryViewController else { return }
       let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor: UIColor(named: "main")]
       controller.title = "新增寵物日記"
        self.present(nav, animated: true, completion: nil)
       }




}
