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

    // MARK: - Can consider moving to VM
    var viewModel = HomePageViewModel()
    var tempScrollYPosition: CGFloat?
    var transparentView = UIView()
    var tableView = UITableView()
    let menuHeight: CGFloat = 250

    // MARK: - VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewModels()
        setMenu()
        setCollectionView()
        setTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchUserData()
        navigationController?.navigationBar.standardAppearance = NavigationBarStyle.transparentBackground.barAppearance

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.standardAppearance = NavigationBarStyle.whiteBgWithMainColorTint.barAppearance
    }

    override func viewDidLayoutSubviews() {

        backGroundview.layer.cornerRadius = 30

    }

    // MARK: - Default setting

    private func setTableView() {
        tableView.isScrollEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuTableViewCell.identifier)
    }

    private func setCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func setViewModels() {
        viewModel.userDataDidLoad = { [weak self] in
            self?.collectionView.reloadData()
        }
        viewModel.userNotificationsDidChange = { [weak self] in
            self?.collectionView.reloadData()
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
        tableView.tintColor = UIColor.mainColor
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

    // MARK: - User interaction respond
    private func showSupplyListPage() {
        let storyboard = UIStoryboard(name: "Supplies", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: ListTableViewController.identifier) as? ListTableViewController else { return }
        self.navigationController?.show(controller, sender: nil)
    }

    private func showDiaryDetailPage(diaryId: String) {
        FirebaseManager.shared.fetchDiary(diaryId: diaryId) { result in
            switch result {
            case .success(let diary):
                let storyboard = UIStoryboard(name: "Diary", bundle: nil)
                let detailController = storyboard.instantiateViewController(identifier: "DiaryDetailViewController", creator: { coder in
                   DiaryDetailViewController(coder: coder, diary: diary)
                })
                self.navigationController?.show(detailController, sender: nil)
            case .failure(let error):
                print(error)
            }
        }
    }

    private func showCreatePetPage() {
        let storyboard = UIStoryboard(name: "Pet", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: CreatePetViewController.identifier) as? CreatePetViewController else { return }
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mainColor]
        controller.presentMode = .create
        self.present(nav, animated: true, completion: nil)
    }

    private func showPetDiaries(pet: Pet) {
        let storyboard = UIStoryboard(name: "Diary", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: UserDiariesViewController.identifier) as? UserDiariesViewController else { return }
        controller.title = "\(pet.name)的寵物日記"
        controller.userDiaryWallViewModel.petIds = [pet.petId]
        self.navigationController?.show(controller, sender: nil)
    }

}
// MARK: - UICollectionViewDataSource
extension HomePageViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch viewModel.sections[section] {
        case .hero:

            return 1

        case .catalog:

            return viewModel.catalogSection.count

        case .petNotification:

            return viewModel.notificationModels.value.count

        case .pets:

            return viewModel.pets.value.count + 1

        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch viewModel.sections[indexPath.section] {

        case .hero:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WellcomeCollectionViewCell.identifier, for: indexPath) as? WellcomeCollectionViewCell else { assertionFailure()
                return UICollectionViewCell() }
            cell.setup(userName: viewModel.userName.value, petsCount: viewModel.usersPetsIds.value.count)

            return cell

        case .catalog:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatalogCollectionViewCell.identifier, for: indexPath) as? CatalogCollectionViewCell else {
                assertionFailure()
                return UICollectionViewCell() }
            let section = viewModel.catalogSection[indexPath.row]
            cell.setup(title: section.titleAndIcon.title, iconName: section.titleAndIcon.icon)

            return cell

        case .petNotification:

            // swiftlint:disable:next line_length
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PetNotificationCollectionViewCell.identifier, for: indexPath) as? PetNotificationCollectionViewCell else { assertionFailure()
                return UICollectionViewCell() }
            cell.setup(viewModel: viewModel.notificationModels.value[indexPath.row])
            cell.didTapCancel = { [weak self] in
                self?.viewModel.removeNotification(indexPath: indexPath.row)
            }

            cell.didTapSupplyNotification = { [weak self] _ in
                self?.showSupplyListPage()
                self?.viewModel.removeNotification(indexPath: indexPath.row)
            }

            cell.didTapCommentNotification = { [weak self] diaryId in
                self?.showDiaryDetailPage(diaryId: diaryId)
                self?.viewModel.removeNotification(indexPath: indexPath.row)
            }

            return cell

        case .pets:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PetCollectionViewCell.identifier, for: indexPath)as? PetCollectionViewCell else {
                assertionFailure()
                return UICollectionViewCell() }

            // Check is last card, if is, create new pet
            if indexPath.row == viewModel.pets.value.count {

                cell.setupBlankDiaryBook()
                cell.didTapCard = { [weak self] in
                    self?.showCreatePetPage()
                }

            } else {

                let pet = viewModel.pets.value[indexPath.row]
                cell.setup(petImage: pet.petThumbnail?.url ?? "", petName: pet.name, petBirthday: pet.healthInfo.birthday)
                cell.didTapCard = { [weak self] in
                    self?.showPetDiaries(pet: pet)
                }
            }

            return cell
        }
    }
}

// MARK: - CollectionViewDelegate

extension HomePageViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch viewModel.sections[indexPath.section] {
        case .hero:
            return

        case .catalog:

            switch indexPath.row {

            case 0:

                let storyboard = UIStoryboard(name: "Diary", bundle: nil)

                guard let controller = storyboard.instantiateViewController(withIdentifier: UserDiariesViewController.identifier) as? UserDiariesViewController else { return }

                self.navigationController?.show(controller, sender: nil)

            case 1:

                let storyboard = UIStoryboard(name: "Supplies", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: ListTableViewController.identifier) as? ListTableViewController else { return }

                self.navigationController?.show(controller, sender: nil)

            case 2:

                let storyboard = UIStoryboard(name: "Pet", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: PetsListTableViewController.identifier) as? PetsListTableViewController else { return }

                self.navigationController?.show(controller, sender: nil)

            case 3:

                let storyboard = UIStoryboard(name: "Goal", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: GoalViewController.identifier) as? GoalViewController else { return }

                self.navigationController?.pushViewController(controller, animated: true)

            default:
                return
            }
        case .petNotification:
            return
        case .pets:
            return
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        DispatchQueue.main.async {

            guard let tempScrollYPosition = self.tempScrollYPosition else {

                self.tempScrollYPosition = scrollView.contentOffset.y

            return
        }

        let temp = tempScrollYPosition - scrollView.contentOffset.y

            self.backGroundCardConstraint.constant += temp * 2.8
            self.tempScrollYPosition = scrollView.contentOffset.y

        }
    }
}

// MARK: - Setting Menu TableView
extension HomePageViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.identifier, for: indexPath) as? MenuTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = viewModel.settingOptions[indexPath.row].title
        cell.settingImage.image = UIImage(systemName: viewModel.settingOptions[indexPath.row].icon) ?? UIImage()
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch viewModel.settingOptions[indexPath.row] {

        case .account:

            let storyboard = UIStoryboard(name: "User", bundle: nil)

            guard let controller = storyboard.instantiateViewController(withIdentifier: "UserAccountTableViewController") as? UserAccountTableViewController else { return }
            controller.user = FirebaseManager.shared.currentUser
            removeSettingMenu()
            self.navigationController?.show(controller, sender: nil)

        case .blockUser:

            let storyboard = UIStoryboard(name: "User", bundle: nil)

            guard let controller = storyboard.instantiateViewController(withIdentifier: "BlockPetsListTableViewController") as? BlockPetsListTableViewController else { return }
            removeSettingMenu()
            self.navigationController?.show(controller, sender: nil)

        case .logout:

            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            removeSettingMenu()
            self.dismiss(animated: true, completion: nil)
            let viewController = SignInViewController()
            guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
            window.rootViewController = viewController
            window.makeKeyAndVisible()

        }
    }

    func removeSettingMenu() {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        // remove menu
        window.subviews.last?.removeFromSuperview()
        // remove BlackBackground
        window.subviews.last?.removeFromSuperview()
    }
}

// MARK: - UICollectionViewLayout

extension HomePageViewController {

    // swiftlint:disable:next function_body_length
    func createLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in

            switch self.viewModel.sections[sectionIndex] {

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
