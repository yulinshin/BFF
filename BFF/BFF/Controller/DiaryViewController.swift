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
        case diary(Diary)
        var pet: Pet? {
            if case .pet(let pet) = self {
                return pet
            } else {
                return nil
            }
        }

        var diary: Diary? {
            if case .diary(let diary) = self {
                return diary
            } else {
                return nil
            }
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.diary?.diaryId == rhs.diary?.diaryId && lhs.pet?.petId == rhs.pet?.petId
          }

        func hash(into hasher: inout Hasher) {
           hasher.combine(pet?.petId)
            hasher.combine(diary?.diaryId)
        }
    }

    var diaries = [Item]() {
        didSet {
            applySnapshot()
            diariesCollectionView.reloadData()
        }
    }

    var userPetIds = [String]()

    // from HomePageVC
    var userPetsData = [Item]() {
        didSet {
            applySnapshot()
            selectedPetsCollectionView.reloadData()
        }
    }
    var showPets = ["1", "2"] {
        didSet {
            diariesCollectionView.reloadData()
        }
    }

    private lazy var diariesDataSource = makeDiariesDataSource()
    private lazy var petsDataSource = makePetsDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedPetsCollectionView.delegate = self
        diariesCollectionView.delegate = self
        let diaryNib = UINib(nibName: "DairyPhotoCell", bundle: nil)
        diariesCollectionView.register(diaryNib, forCellWithReuseIdentifier: DairyPhotoCell.identifier)
        let petNib = UINib(nibName: "SelectedPetsCollectionViewCell", bundle: nil)
        selectedPetsCollectionView.register(petNib, forCellWithReuseIdentifier: SelectedPetsCollectionViewCell.identifier)
        diariesCollectionView.dataSource = diariesDataSource
        selectedPetsCollectionView.dataSource = petsDataSource
        diariesCollectionView.collectionViewLayout = creatLayout(type: .single)
        selectedPetsCollectionView.allowsMultipleSelection = true
        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchData()
    }

    func fetchData() {

        FirebaseManager.shared.fetchDiaries { result in

            switch result {

            case .success(let diaries):

                var diaryItems = [Item]()

                diaries.forEach { diary in
                    diaryItems.append(Item.diary(diary))
                }
                self.diaries = diaryItems

            case .failure(let error):
                print("fetchData.failure\(error)")

            }
        }

        FirebaseManager.shared.fetchPets(petIds: userPetIds) { result in

            switch result {

            case .success(let pets):

                var petsDataItem = [Item]()
                pets.forEach { pet in
                    petsDataItem.append(Item.pet(pet))
                    print("Pet = \(pet)")
                }
                self.userPetsData = petsDataItem

            case .failure(let error):
                print("fetchData.failure\(error)")

            }

        }

    }

    func applySnapshot(animatingDifferences: Bool = true) {
        var diariesSnapshot = Snapshot()
        diariesSnapshot.appendSections([.all])
        diariesSnapshot.appendItems(diaries, toSection: .all)
        diariesDataSource.apply(diariesSnapshot, animatingDifferences: false)

        var myPetsSnapshot = Snapshot()
        myPetsSnapshot.appendSections([.all])
        myPetsSnapshot.appendItems(userPetsData, toSection: .all)
        petsDataSource.apply(myPetsSnapshot, animatingDifferences: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        for (index, item) in userPetsData.enumerated() {
            guard let petId = item.pet?.petId,
                  let cell = selectedPetsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SelectedPetsCollectionViewCell else { return }
            if showPets.contains(petId) {
                selectedPetsCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: [])
                cell.selectBackground.layer.borderColor = UIColor.orange.cgColor
                cell.selectBackground.layer.borderWidth = 1
            }
        }
    }

    // MARK: - dataSource

    func makeDiariesDataSource() -> DataSource {

        let dataSource = DataSource(collectionView: diariesCollectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DairyPhotoCell.identifier, for: indexPath) as? DairyPhotoCell

            guard let imageStr = item.diary?.images.first?.url else { return cell }
            cell?.configure(with: PhotoCellViewlModel(with: imageStr))

            return cell
        }

        return dataSource

    }

    func makePetsDataSource() -> DataSource {

        let dataSource = DataSource(collectionView: selectedPetsCollectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedPetsCollectionViewCell.identifier, for: indexPath) as? SelectedPetsCollectionViewCell

            guard let imageStr = item.pet?.petThumbnail?.url,
                  let petId = item.pet?.petId else { return cell }
            cell?.congfigure(with: PhotoCellViewlModel(with: imageStr), petId: petId)
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
            guard let petId = cell.petId else { return }
            if showPets.contains(petId) {
               return
            } else {
                showPets.insert(petId, at: indexPath.item)
            }
        } else {

            let storyboard = UIStoryboard(name: "Diary", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
            controller.viewModel = DetialViewModel(from: diaries[indexPath.row].diary!)
            self.navigationController?.show(controller, sender: nil)

        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == selectedPetsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor.orange.cgColor
            cell.selectBackground.layer.borderWidth = 0

            guard let petId = cell.petId else { return }
            if showPets.contains(petId) {
                showPets.remove(at: indexPath.item)
            } else {
                return
            }
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
