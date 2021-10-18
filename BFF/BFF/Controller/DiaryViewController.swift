//
//  DiaryViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import UIKit

class DiaryViewController: UIViewController {

    @IBOutlet weak var selectedPetsCollectionView: UICollectionView!
    @IBOutlet weak var diariesCollectionView: UICollectionView!

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum LayoutType {
        case grid
        case single
    }

    enum Section: String {
        case all
    }

    enum Item: Hashable {

        case pet(Pet)
        case diary(String)

        var pet: Pet? {
            if case .pet(let pet) = self {
                return pet
            } else {
                return nil
            }
        }

        var diary: String? {
            if case .diary(let diary) = self {
                return diary
            } else {
                return nil
            }
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.diary == rhs.diary && lhs.pet?.petId == rhs.pet?.petId
          }

        func hash(into hasher: inout Hasher) {
           hasher.combine(pet?.petId)
           hasher.combine(diary)
        }

    }

//    var diaries = [Item]()
    var diaries =  [
        Item.diary("https://images.pexels.com/photos/160846/french-bulldog-summer-smile-joy-160846.jpeg?cs=srgb&dl=pexels-pixabay-160846.jpg&fm=jpg/"),
        Item.diary("https://images.pexels.com/photos/4587998/pexels-photo-4587998.jpeg?cs=srgb&dl=pexels-anna-shvets-4587998.jpg&fm=jpg"),
        Item.diary("https://images.pexels.com/photos/2449536/pexels-photo-2449536.jpeg?cs=srgb&dl=pexels-megan-markham-2449536.jpg&fm=jpg"),
        Item.diary("https://images.pexels.com/photos/4730048/pexels-photo-4730048.jpeg?cs=srgb&dl=pexels-maria-perez-4730048.jpg&fm=jpg"),
        Item.diary("https://images.pexels.com/photos/4079375/pexels-photo-4079375.jpeg?cs=srgb&dl=pexels-kelatout-4079375.jpg&fm=jpg")

    ]

    var myPets = [
        // swiftlint:disable:next line_length
        Item.pet(Pet(petId: "lnx5II0UzFrDF53H9OSz", name: "豆豆", userId: "", healthInfo: HealthInfo(allergy: "", birthday: "", chipId: "", gender: "", note: "", type: "", weight: 0), medicalRecords: [MedicalRecord](), petThumbnail: "https://images.pexels.com/photos/4587971/pexels-photo-4587971.jpeg?cs=srgb&dl=pexels-anna-shvets-4587971.jpg&fm=jpg")),
        // swiftlint:disable:next line_length
        Item.pet(Pet(petId: "1111111111", name: "豆2222豆", userId: "22", healthInfo: HealthInfo(allergy: "22", birthday: "22", chipId: "", gender: "222", note: "222", type: "222", weight: 0), medicalRecords: [MedicalRecord](), petThumbnail: "https://images.pexels.com/photos/4079375/pexels-photo-4079375.jpeg?cs=srgb&dl=pexels-kelatout-4079375.jpg&fm=jpg"))
    ]

    private lazy var diariesDataSource = makeDiariesDataSource()
    private lazy var petsDataSource = makePetsDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedPetsCollectionView.delegate = self
        diariesCollectionView.delegate = self
        let diaryNib = UINib(nibName: "DiaryCollectionViewCell", bundle: nil)
        diariesCollectionView.register(diaryNib, forCellWithReuseIdentifier: "DiaryCollectionViewCell")
        let petNib = UINib(nibName: "SelectedPetsCollectionViewCell", bundle: nil)
        selectedPetsCollectionView.register(petNib, forCellWithReuseIdentifier: "SelectedPetsCollectionViewCell")
        diariesCollectionView.dataSource = diariesDataSource
        selectedPetsCollectionView.dataSource = petsDataSource
        diariesCollectionView.collectionViewLayout = creatLayout(type: .single)
        fetchData()

    }

    func fetchData() {
        var diariesSnapshot = Snapshot()
        diariesSnapshot.appendSections([.all])
        diariesSnapshot.appendItems(diaries, toSection: .all)
        diariesDataSource.apply(diariesSnapshot, animatingDifferences: false)

        var myPetsSnapshot = Snapshot()
        myPetsSnapshot.appendSections([.all])
        myPetsSnapshot.appendItems(myPets, toSection: .all)
        petsDataSource.apply(myPetsSnapshot, animatingDifferences: false)

    }

    // MARK: - dataSource

    func makeDiariesDataSource() -> DataSource {

        let dataSource = DataSource(collectionView: diariesCollectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCollectionViewCell", for: indexPath) as? DiaryCollectionViewCell
            guard let imageStr = item.diary else { return cell }
            print (imageStr)
            cell?.image.loadImage(imageStr)

            return cell

        }

        return dataSource

    }

    func makePetsDataSource() -> DataSource {

        let dataSource = DataSource(collectionView: selectedPetsCollectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedPetsCollectionViewCell", for: indexPath) as? SelectedPetsCollectionViewCell
            guard let imageStr = item.pet?.petThumbnail else { return cell }
            print (imageStr)
            cell?.image.loadImage(imageStr)
            cell?.isSelected = true
            return cell

        }

        return dataSource

    }



    // MARK: - diariesCollectionViewCompostionLayout

    func creatLayout(type: LayoutType) -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout{ (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection in

            switch type {
            case .grid:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalWidth(1/3))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .none

                return section

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

extension DiaryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == selectedPetsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor.orange.cgColor
            cell.selectBackground.layer.borderWidth = 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == selectedPetsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor.orange.cgColor
            cell.selectBackground.layer.borderWidth = 0
        }
    }

}

extension DiaryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == selectedPetsCollectionView {
            return CGSize(width: 70, height: 70)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}
