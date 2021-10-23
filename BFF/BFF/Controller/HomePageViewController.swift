//
//  ViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/17.
//

import UIKit

class HomePageViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    enum Section: CaseIterable {
        case hero
        case catalog
        case petNotifycation
        case pets
    }

    var sections = Section.allCases

    var catalogIcon = ["diary", "supply", "heart", "goal"]
    var catalogLable =  ["相簿集", "用品", "健康", "成就"]

    var viewModel = HomePageViewModel()

    var notificationCount = 0 {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 2))
        }
    }

    var userPetsCount = 0 {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 3))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self

        viewModel.notifiactions.bind { notifications in
            self.notificationCount = notifications.count
            print("UpdateNotification")
        }
        viewModel.usersPetsIds.bind { userPetsIds in
            self.userPetsCount = userPetsIds.count
            print("userPets")

        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           let barAppearance =  UINavigationBarAppearance()
           barAppearance.configureWithTransparentBackground()
        barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.orange]

           navigationController?.navigationBar.standardAppearance = barAppearance
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let barAppearance =  UINavigationBarAppearance()
        barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.orange]
        navigationController?.navigationBar.standardAppearance = barAppearance
    }

    // MARK: - UICollectionViewLayout

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

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(110))
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

                let layoutSection = NSCollectionLayoutSection(group: group)

                return layoutSection

            case .pets:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.86), heightDimension: .fractionalHeight(0.55))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .groupPaging

                return layoutSection
            }
        }
        return layout
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

                default:
                    return
                }
            }
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

            return notificationCount

        case 3:

            return userPetsCount + 1

        default:

            fatalError("SecionIndexOutOfRange")

        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {

        case 0:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WellcomeCollectionViewCell", for: indexPath)as? WellcomeCollectionViewCell else { fatalError() }

            viewModel.userName.bind { name in

                self.viewModel.pets.bind { pets in

                    cell.setup(userName: name, petsCount: pets.count)

                }
            }

            cell.creatButtonTap = {
                let storyboard = UIStoryboard(name: "Diary", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "CreatDiaryViewController") as? CreatDiaryViewController else { return }
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                nav.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor.orange]
                self.present(nav, animated: true, completion: nil)
            }
            
            return cell

        case 1:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCollectionViewCell", for: indexPath)as? CatalogCollectionViewCell else { fatalError() }

            cell.setup(title: catalogLable[indexPath.row], iconName: catalogIcon[indexPath.row])

            return cell

        case 2:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetNotificationCollectionViewCell", for: indexPath)as? PetNotificationCollectionViewCell else { fatalError() }

            viewModel.notifiactions.bind { notifications in

                let notification = notifications[indexPath.row]

                self.viewModel.pets.bind { pets in

                    pets.forEach { pet in
                        if notification.fromPets.contains(pet.petId) {

                            cell.setup(petName: pet.name, content: notification.content, petImage: pet.petThumbnail?.url ?? "")

                            return

                        }
                    }

                }

            }

            return cell

        case 3:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCollectionViewCell", for: indexPath)as? PetCollectionViewCell else { fatalError() }

                if indexPath.row == userPetsCount {

                    cell.setupBlankDiaryBook()
                    cell.didTapCard = {
                        let storyboard = UIStoryboard(name: "Pet", bundle: nil)
                        guard let controller = storyboard.instantiateViewController(withIdentifier: "CreatPetViewController") as? CreatPetViewController else { return }
                        let nav = UINavigationController(rootViewController: controller)
                        nav.modalPresentationStyle = .fullScreen
                        nav.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor.orange]
                        controller.presentMode = .creat
                        self.present(nav, animated: true, completion: nil)
                    }

                } else {

                    viewModel.pets.bind { pets in
                    let pet = pets[indexPath.row]
                        cell.setup(petImage: pet.petThumbnail?.url ?? "")
                    cell.didTapCard = {
                        let storyboard = UIStoryboard(name: "Diary", bundle: nil)
                        guard let controller = storyboard.instantiateViewController(withIdentifier: "DiaryViewController") as? DiaryViewController else { return }
                        controller.userPetIds = [pet.petId]
                        controller.showSelectedPetsCollectionView = false
                        self.navigationController?.show(controller, sender: nil)
                    }

                }
            }

            return cell
        default:
            fatalError("SecionIndexOutOfRange")

        }

    }
}
