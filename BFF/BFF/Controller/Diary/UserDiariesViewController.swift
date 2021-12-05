//
//  UserDiariesViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import UIKit

class UserDiariesViewController: UIViewController {

    @IBOutlet weak var diariesCollectionView: UICollectionView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!

    static var identifier = "UserDiariesViewController"

    var layoutType = LayoutType.grid
    var userDiaryWallViewModel = UserDiaryWallViewModel()
    var showPets = [String]()

    deinit {
        print("DiaryViewController DIE")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        userDiaryWallViewModel.collectionView = diariesCollectionView
        diariesCollectionView.delegate = self
        diariesCollectionView.dataSource = userDiaryWallViewModel.diariesDataSource
        userDiaryWallViewModel.fetchUserDiaries()
        userDiaryWallViewModel.didUpDateData = {
            self.statusImage.isHidden = true
            self.statusLabel.isHidden = true
        }
        let diaryNib = UINib(nibName: "DairyPhotoCell", bundle: nil)
        diariesCollectionView.register(diaryNib, forCellWithReuseIdentifier: DairyPhotoCell.identifier)
        diariesCollectionView.collectionViewLayout = createLayout(type: .grid)

        self.navigationController?.navigationBar.tintColor = UIColor.mainColor

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Filter"), style: .done, target: self, action: #selector(switchShowList))

        statusLabel.isHidden = false
        statusLabel.text = "翻閱日記中..."
        statusImage.isHidden = false
        statusImage.image = UIImage(named: "LoadDiary")
        userDiaryWallViewModel.getDataFailure = {  [weak self] in
                self?.statusLabel.text = "無法取得毛小孩日記！ 請確認網路連線狀態"
                self?.statusImage.image = UIImage(named: "NoDiary")
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.navigationController?.navigationBar.backgroundColor = .white
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = .clear
    }

    @objc func creatDiary() {

            let storyboard = UIStoryboard(name: "Diary", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "CreateDiaryViewController") as? CreateDiaryViewController else { return }
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor: UIColor.mainColor]
            self.present(nav, animated: true, completion: nil)
    }

    @objc func switchShowList() {
        switch layoutType {

        case .grid:

            layoutType = .single
            diariesCollectionView.collectionViewLayout = createLayout(type: .single)
            diariesCollectionView.reloadData()

        case .single:

            layoutType = .grid
            diariesCollectionView.collectionViewLayout = createLayout(type: .grid)
            diariesCollectionView.reloadData()
        }
    }
    

    // MARK: - diariesCollectionViewCompositionLayout

    // swiftlint:disable:next function_body_length
    func createLayout(type: LayoutType) -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection in

            switch type {
            case .grid:

                    // item
                    // First type: 1/3 view.width square
                    let tripletSquareItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1/3),
                            heightDimension: .fractionalWidth(1/3)
                        )
                    )
                    tripletSquareItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                    // First type: 1/3 view.width square
                    let tripletSquareItemVertical = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(1)
                        )
                    )
                    tripletSquareItemVertical.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                    // Second type: 3/2 view.width large square
                    let largeSquareItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(2/3),
                            heightDimension: .fractionalWidth(2/3)
                        )
                    )
                    largeSquareItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                    // group
                    // 1. MAIN, 1/3 square x 3
                    let threeItemGroup = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalWidth(1/3)
                        ),
                        subitem: tripletSquareItem,
                        count: 3
                    )

                    // 2. 1/3 square x 2 vertical
                    let verticalGroup = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1/3),
                            heightDimension: .fractionalWidth(2/3)
                        ),
                        subitem: tripletSquareItemVertical,
                        count: 2
                    )

                    // 3. MAIN, one large at left, 2 small at right
                    let horizontalComboOneGroup = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalWidth(2/3)
                        ),
                        subitems: [
                            largeSquareItem,
                            verticalGroup
                        ]
                    )

                    // 4. MAIN, 2 small at left, one large at right
                    let horizontalComboTwoGroup = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalWidth(2/3)
                        ),
                        subitems: [
                            verticalGroup,
                            largeSquareItem
                        ]
                    )

                    let finalGroup = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalWidth(2.0)
                        ),
                        subitems: [
                            horizontalComboOneGroup,
                            threeItemGroup,
                            horizontalComboTwoGroup,
                            threeItemGroup
                        ]
                    )
                    return NSCollectionLayoutSection(group: finalGroup)

            case .single:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .none

                return section

            }
        }
        return layout
    }

}

extension UserDiariesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

            let storyboard = UIStoryboard(name: "Diary", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        controller.viewModel = DetailViewModel(from: userDiaryWallViewModel.showingDiaries.value[indexPath.row])
            self.navigationController?.show(controller, sender: nil)

    }
}
