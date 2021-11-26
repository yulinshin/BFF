//
//  GoalViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/31.
//

import UIKit

class GoalViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var cellArray = ["GoalCollectionViewCellA", "GoalCollectionViewCellB", "GoalCollectionViewCellC", "GoalCollectionViewCellD"]

    static var identifier = "GoalViewController"

    override func viewDidLoad() {
      super.viewDidLoad()

        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
    }
}

// MARK: - UICollectionView Datasource
extension GoalViewController : UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch cellArray[indexPath.row] {

        case "GoalCollectionViewCellA":

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellArray[indexPath.row], for: indexPath) as? GoalCollectionViewCellA else { return UICollectionViewCell() }
            return cell
        case "GoalCollectionViewCellB":

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellArray[indexPath.row], for: indexPath) as? GoalCollectionViewCellB else { return UICollectionViewCell() }
            return cell
        case "GoalCollectionViewCellC":

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellArray[indexPath.row], for: indexPath) as? GoalCollectionViewCellC else { return UICollectionViewCell() }
            return cell
        case "GoalCollectionViewCellD":

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellArray[indexPath.row], for: indexPath) as? GoalCollectionViewCellD else { return UICollectionViewCell() }
                collectionView.reloadData()

            return cell
        default:
           print("OutOfRange")
            return UICollectionViewCell()
        }

    }

 func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellArray.count
    }


}

// MARK: - UICollectionViewLayout

extension GoalViewController {

    func createLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .none
                layoutSection.interGroupSpacing = 0

                return layoutSection
        }

        return layout
    }

}
