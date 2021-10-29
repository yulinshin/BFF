//
//  ViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/17.
//

import UIKit

class HomePageViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var backGroundview: UIView!

    @IBOutlet weak var backgroundcardConstraint: NSLayoutConstraint!

    enum Section: CaseIterable {
        case hero
        case catalog
        case petNotifycation
        case pets
    }

    // MARK: - Can consider moving to VM -
    var sections = Section.allCases
    var catalogIcon = ["diary", "supply", "heart", "goal"]
    var catalogLable =  ["相簿集", "用品", "健康", "成就"]
    var viewModel = HomePageViewModel()
    var tempScrollYPosition: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.navigationController?.navigationBar.tintColor = UIColor(named: "main")

        viewModel.userDataDidLoad = {
            self.collectionView.reloadData() // 獲得使用者資料後 進行reloadCollectionView
        }

        viewModel.userNotifiactionsDidChange = {
            self.collectionView.reloadData() // 當監聽的Notification資料更新後 進行reloadCollectionView
        }

    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let barAppearance =  UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = barAppearance

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let barAppearance =  UINavigationBarAppearance()
        barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(named: "main")]
        barAppearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = barAppearance

    }

    override func viewDidLayoutSubviews() {

        backGroundview.layer.cornerRadius = 30

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

                self.navigationController?.show(controller, sender: nil)

            case 1: // Supply

                let storyboard = UIStoryboard(name: "Supplies", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "ListTableViewController") as? ListTableViewController else { return }

                self.navigationController?.show(controller, sender: nil)

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
            self.backgroundcardConstraint.constant += temp * 2.8
        }

        self.tempScrollYPosition = scrollView.contentOffset.y

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

            return 1

        case 1:

            return catalogIcon.count

        case 2:

            return viewModel.notifiactions.value.count

        case 3:

            return viewModel.pets.value.count + 1

        default:

            fatalError("SecionIndexOutOfRange")

        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {

        case 0:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WellcomeCollectionViewCell", for: indexPath)as? WellcomeCollectionViewCell else { fatalError() }

            cell.setup(userName: viewModel.userName.value, petsCount: viewModel.usersPetsIds.value.count)

            cell.creatButtonTap = {
                let storyboard = UIStoryboard(name: "Diary", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "CreatDiaryViewController") as? CreatDiaryViewController else { return }
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                nav.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor: UIColor(named: "main")]
                self.present(nav, animated: true, completion: nil)
            }
            
            return cell

        case 1:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCollectionViewCell", for: indexPath)as? CatalogCollectionViewCell else { fatalError() }

            cell.setup(title: catalogLable[indexPath.row], iconName: catalogIcon[indexPath.row])

            return cell

        case 2:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetNotificationCollectionViewCell", for: indexPath)as? PetNotificationCollectionViewCell else { fatalError() }

            let notification = viewModel.notifiactions.value[indexPath.row]
            viewModel.pets.value.forEach { pet in

                if notification.fromPets.contains(pet.petId) {

                    cell.setup(petName: pet.name, content: notification.content, petImage: pet.petThumbnail?.url ?? "")

                    return
                }
            }

            return cell

        case 3:

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

                cell.setup(petImage: pet.petThumbnail?.url ?? "")
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

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)

                let layoutSection = NSCollectionLayoutSection(group: group)

                layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 6, trailing: 24)
                layoutSection.orthogonalScrollingBehavior = .none

                return layoutSection

            case .petNotifycation:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))

                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))

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
                group.contentInsets.trailing = 8
                group.contentInsets.leading = 8

                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .groupPaging
                layoutSection.interGroupSpacing = -36

                return layoutSection
            }
        }
        return layout
    }

}
