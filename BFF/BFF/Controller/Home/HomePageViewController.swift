//
//  ViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/17.

import UIKit
import FirebaseAuth

class HomePageViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var backGroundview: UIView!

    @IBOutlet weak var backGroundCardConstraint: NSLayoutConstraint!

    enum Section: CaseIterable {
        case hero
        case catalog
        case petNotification
        case pets
    }

    // MARK: - Can consider moving to VM -
    var sections = Section.allCases
//    var catalogIcon = ["diary", "supply", "heart", "goal"]
//    var catalogLabel =  ["相簿集", "用品", "健康", "成就"]
    var catalogIcon = ["diary", "supply", "heart"]
    var catalogLabel =  ["相簿集", "用品", "健康"]
    var viewModel = HomePageViewModel()
    var tempScrollYPosition: CGFloat?
    var transparentView = UIView()
    var tableView = UITableView()
    var settingArray = ["帳戶設定", "黑名單管理", "登出"]
    var settingPicArray = ["person.circle", "x.square.fill", "rectangle.portrait.and.arrow.right.fill"] // Change Icon if time allows
    let menuHeight: CGFloat = 250


// MARK: - VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewModels()
        setMenu()
        setCollectionView()
        setTableView()
        viewModel.listenNotificationData()


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.listenUserData()
        viewModel.fetchUserPetsData()
        let barAppearance =  UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = barAppearance

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let barAppearance =  UINavigationBarAppearance()
        barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "main") ]
        barAppearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = barAppearance

    }

    override func viewDidLayoutSubviews() {

        backGroundview.layer.cornerRadius = 30

    }

// MARK: - Default setting

    fileprivate func setTableView() {
        tableView.isScrollEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    fileprivate func setCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    fileprivate func setViewModels() {
        // After obtaining user data, perform reloadCollectionView
        viewModel.userDataDidLoad = {
            self.collectionView.reloadData()
        }
        // When the monitored Notification data is updated, perform reloadCollectionView
        viewModel.userNotificationsDidChange = {
            self.collectionView.reloadData()
        }
    }

    fileprivate func setMenu() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "MenuTab"), style: .done, target: self, action: #selector(showSideMenu))
        self.navigationItem.rightBarButtonItem?.tintColor = .white
    }

// MARK: - User settings menu

    @objc func showSideMenu() {

        // Prevent homepage background from moving
        tableView.isScrollEnabled = false

        guard let window =  UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }

        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        transparentView.frame = self.view.frame
        window.addSubview(transparentView)

        let screenSize = UIScreen.main.bounds.size
        tableView.tintColor = UIColor(named: "main")
        tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: menuHeight)
        window.addSubview(tableView)
        tableView.layer.cornerRadius = 10

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: 0, y: screenSize.height - self.menuHeight, width: screenSize.width, height: self.menuHeight)
        }, completion: nil)
    }

    @objc func onClickTransparentView() {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.menuHeight)
        }, completion: nil)
    }

}

// MARK: - UICollectionViewDataSource
extension HomePageViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch section {
        case 0:

            return 1    // Welcome title

        case 1:

            return catalogIcon.count    // Action Catalog Section

        case 2:

            return viewModel.notifications.value.count // Notifications Section

        case 3:

            return viewModel.pets.value.count + 1 // User pets section, last one for add new pet

        default:

            fatalError("SecionIndexOutOfRange")

        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {

        case 0: // Welcome title

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WellcomeCollectionViewCell", for: indexPath)as? WellcomeCollectionViewCell else { return UICollectionViewCell() }

            cell.setup(userName: viewModel.userName.value, petsCount: viewModel.usersPetsIds.value.count)

            return cell

        case 1: // Action Catalog Section

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCollectionViewCell", for: indexPath)as? CatalogCollectionViewCell else { fatalError() }

            cell.setup(title: catalogLabel[indexPath.row], iconName: catalogIcon[indexPath.row])

            return cell

        case 2: // Notifications Section

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetNotificationCollectionViewCell", for: indexPath)as? PetNotificationCollectionViewCell else { fatalError() }

            let notification = viewModel.notifications.value[indexPath.row]
            viewModel.pets.value.forEach { pet in

                if notification.fromPets.contains(pet.petId) {

                    cell.setup(petName: pet.name, content: notification.content, petImage: pet.petThumbnail?.url ?? "")
                    cell.didTapCancle = {
                        self.viewModel.removeNotification(indexPath: indexPath.row)
                    }

                    return
                }
            }

            return cell

        case 3: // User pets section, last one for add new pet

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCollectionViewCell", for: indexPath)as? PetCollectionViewCell else { fatalError() }

            if indexPath.row == viewModel.pets.value.count {

                cell.setupBlankDiaryBook()
                cell.didTapCard = {

                    let storyboard = UIStoryboard(name: "Pet", bundle: nil)
                    guard let controller = storyboard.instantiateViewController(withIdentifier: "CreatPetViewController") as? CreatPetViewController else { return }
                    let nav = UINavigationController(rootViewController: controller)
                    nav.modalPresentationStyle = .fullScreen
                    nav.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor(named: "main")]
                    controller.presentMode = .creat
                    self.present(nav, animated: true, completion: nil)

                }

            } else {

                let pet =  viewModel.pets.value[indexPath.row]

                cell.setup(petImage: pet.petThumbnail?.url ?? "", petName: pet.name, petBirthday: pet.healthInfo.birthday)
                cell.didTapCard = {
                    let storyboard = UIStoryboard(name: "Diary", bundle: nil)
                    guard let controller = storyboard.instantiateViewController(withIdentifier: "DiaryViewController") as? DiaryViewController else { return }
                    controller.userPetIds = [pet.petId]
                    controller.title = "\(pet.name)的寵物日記"
                    controller.showSelectedPetsCollectionView = false
                    self.navigationController?.show(controller, sender: nil)

                }
            }

            return cell

        default:
            fatalError("SecionIndexOutOfRange")

        }
    }
}

// MARK: - CollectionViewDelegate

extension HomePageViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == 1 {
            switch indexPath.row {

            case 0: // Diary

                let storyboard = UIStoryboard(name: "Diary", bundle: nil)

                guard let controller = storyboard.instantiateViewController(withIdentifier: "DiaryViewController") as? DiaryViewController else { return }
                controller.userPetIds = viewModel.usersPetsIds.value
                controller.showSelectedPetsCollectionView = false

                self.navigationController?.show(controller, sender: nil)

            case 1: // Supply

                let storyboard = UIStoryboard(name: "Supplies", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "ListTableViewController") as? ListTableViewController else { return }

                self.navigationController?.show(controller, sender: nil)


            case 2: // Health

                let storyboard = UIStoryboard(name: "Pet", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "PetsListTableViewController") as? PetsListTableViewController else { return }

                self.navigationController?.show(controller, sender: nil)

            case 3: // Goal

                let storyboard = UIStoryboard(name: "Goal", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "GoalViewController") as? GoalViewController else { return }

                self.navigationController?.pushViewController(controller, animated: true)



            default:
                return
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {


        guard let tempScrollYPosition = tempScrollYPosition else {

            tempScrollYPosition = scrollView.contentOffset.y

            return
        }

        let temp = tempScrollYPosition - scrollView.contentOffset.y

        DispatchQueue.main.async {
            self.backGroundCardConstraint.constant += temp * 2.8
        }

        self.tempScrollYPosition = scrollView.contentOffset.y

    }
}

// MARK: - UICollectionViewLayout

extension HomePageViewController {

    func createLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in

            let section = self.sections[sectionIndex]
            switch section {

            case .hero:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .none
                layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 6, trailing: 24)

                return layoutSection

            case .catalog:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.28), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(110))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
                group.interItemSpacing  = .fixed(20)
                let layoutSection = NSCollectionLayoutSection(group: group)

                layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 40, bottom: 6, trailing: 40)
                layoutSection.orthogonalScrollingBehavior = .none

                return layoutSection

            case .petNotification:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(5))

                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(5))

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets.trailing = 8
                group.contentInsets.leading = 8

                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .groupPaging
                layoutSection.interGroupSpacing = -36

                return layoutSection

            case .pets:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))

                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1*6/5))

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets.leading = 0
                group.contentInsets.trailing = 20


                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .groupPaging
                layoutSection.interGroupSpacing = -40
                layoutSection.contentInsets.leading = 8



                return layoutSection
            }
        }
        return layout
    }

}

extension HomePageViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? MenuTableViewCell else {fatalError("Unable to deque cell")}
        cell.lbl.text = settingArray[indexPath.row]
        cell.settingImage.image = UIImage(systemName: settingPicArray[indexPath.row]) ?? UIImage()
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch settingArray[indexPath.row] {

        case "帳戶設定":

            let storyboard = UIStoryboard(name: "User", bundle: nil)

            guard let controller = storyboard.instantiateViewController(withIdentifier: "UserAccountTableViewController") as? UserAccountTableViewController else { return }
            controller.user = viewModel.user

            guard let window =  UIApplication.shared.windows.filter { $0.isKeyWindow}.first else { return }
            transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            transparentView.frame = self.view.frame
            window.subviews.last?.removeFromSuperview()
            window.subviews.last?.removeFromSuperview()

            self.navigationController?.show(controller, sender: nil)

        case "黑名單管理":

            let storyboard = UIStoryboard(name: "User", bundle: nil)

            guard let controller = storyboard.instantiateViewController(withIdentifier: "BlockPetsListTableViewController") as?    BlockPetsListTableViewController else { return }

            guard let window =  UIApplication.shared.windows.filter { $0.isKeyWindow }.first else { return }
            transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            transparentView.frame = self.view.frame
            window.subviews.last?.removeFromSuperview()
            window.subviews.last?.removeFromSuperview()

            self.navigationController?.show(controller, sender: nil)


        case "登出":

            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }



            guard let window =  UIApplication.shared.windows.filter { $0.isKeyWindow }.first else { return }
            transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            transparentView.frame = self.view.frame
            window.subviews.last?.removeFromSuperview()
            window.subviews.last?.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
            let viewController = SignInViewController()
            window.rootViewController = viewController
            window.makeKeyAndVisible()

        default:
            print("outOFrange")
        }

    }
}
