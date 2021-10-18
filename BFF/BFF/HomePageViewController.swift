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

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self

    }


    func createLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

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
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .absolute(300))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .groupPaging

                return layoutSection
            }
        }
        return layout
    }

}

extension HomePageViewController: UICollectionViewDelegate {

}

extension HomePageViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 4 // Return catalogCount
        case 2:
            return 1 // Return petNotificationCount
        case 3:
            return 1 // Return petsCount
        default:
            fatalError("SecionIndexOutOfRange")
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {

        case 0:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WellcomeCollectionViewCell", for: indexPath)as? WellcomeCollectionViewCell else { fatalError() }

            return cell

        case 1:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCollectionViewCell", for: indexPath)as? CatalogCollectionViewCell else { fatalError() }

            return cell

        case 2:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetNotificationCollectionViewCell", for: indexPath)as? PetNotificationCollectionViewCell else { fatalError() }

            return cell

        case 3:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCollectionViewCell", for: indexPath)as? PetCollectionViewCell else { fatalError() }

            return cell

        default:
            fatalError("SecionIndexOutOfRange")

        }

    }

}
