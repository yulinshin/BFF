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

    var sections = [Section.hero, Section.catalog, Section.petNotifycation, Section.pets]

    var catalogIcon = ["diary", "supply", "heart", "goal"]
    var catalogLable =  ["日記本", "用品", "健康", "成就"]

    var user = User(userId: "", email: "", provider: "", providerId: "", userName: "", blockPets: [String](), petsIds: [String]()) {

        didSet {
            collectionView.reloadData()
        }

    }

    var notifications = [Notification]() {

        didSet {
            collectionView.reloadData()
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseManager.shared.fetchUser { result in
            switch result {

            case .success(let user):
                self.user = user

            case .failure(let error):
                print("fetchData.failure\(error)")

            }
        }

        FirebaseManager.shared.fetchNotifications { result in
            switch result {

            case .success(let notifications):
                self.notifications = notifications

            case .failure(let error):
                print("fetchData.failure\(error)")

            }
        }

        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self

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
                layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)

                return layoutSection

            case .catalog:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(120))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)

                let layoutSection = NSCollectionLayoutSection(group: group)

                layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
                layoutSection.orthogonalScrollingBehavior = .none

                return layoutSection

            case .petNotifycation:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)

                return layoutSection

            case .pets:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(0.6))
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
                guard let userPetsId = user.petsIds else { return }
                controller.userPetIds = userPetsId
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

            return notifications.count

        case 3:

            return (user.petsIds?.count ?? 0) + 1

        default:

            fatalError("SecionIndexOutOfRange")

        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {

        case 0:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WellcomeCollectionViewCell", for: indexPath)as? WellcomeCollectionViewCell else { fatalError() }

            cell.setup(userName: user.userName, petsCount: user.petsIds?.count ?? 0)
            cell.creatButtonTap = {
                let storyboard = UIStoryboard(name: "Diary", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "CreatDiaryViewController") as? CreatDiaryViewController else { return }
                var nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            
            return cell

        case 1:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCollectionViewCell", for: indexPath)as? CatalogCollectionViewCell else { fatalError() }

            cell.setup(title: catalogLable[indexPath.row], iconName: catalogIcon[indexPath.row])

            return cell

        case 2:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetNotificationCollectionViewCell", for: indexPath)as? PetNotificationCollectionViewCell else { fatalError() }

            guard let petId = notifications[indexPath.row].fromPets.first else { return cell }

            FirebaseManager.shared.fetchPet(petId: petId) { result in
                switch result {

                case .success(let pet):

                    cell.setup(petName: pet.name, content: self.notifications[indexPath.row].content, petImage: pet.petThumbnail)

                case .failure(let error):

                    print("fetchData.failure\(error)")

                }
            }
            return cell

        case 3:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCollectionViewCell", for: indexPath)as? PetCollectionViewCell else { fatalError() }
            if indexPath.row == user.petsIds?.count {

                cell.setupBlankDiaryBook()

            }else{
                guard let petId = user.petsIds?[indexPath.row] else { return cell }

                FirebaseManager.shared.fetchPet(petId: petId) { result in
                    switch result {

                    case .success(let pet):

                        cell.setup(petImage: pet.petThumbnail)

                    case .failure(let error):

                        print("fetchData.failure\(error)")

                    }
                }

            }

            return cell
        default:
            fatalError("SecionIndexOutOfRange")

        }

    }
}
