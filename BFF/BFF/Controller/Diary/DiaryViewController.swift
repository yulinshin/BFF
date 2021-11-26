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

    @IBOutlet weak var petsTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!

    private var lastContentOffset: CGFloat = 0

    var layoutType = LayoutType.grid

    var showSelectedPetsCollectionView = true
    static var identifier = "DiaryViewController"

    var diaryWallViewModel = DiaryWallViewModel()
    var diaries = [Item]() {
        didSet {
            applySnapshot()
            diariesCollectionView.reloadData()
        }
    }

    var userPetIds = [String]()

    var userPetsData = [Item]() {
        didSet {
            applySnapshot()
            selectedPetsCollectionView.reloadData()
        }
    }

    var showPets = [String]() {
        didSet {
            diaryWallViewModel.filter(petIds: showPets)
        }
    }

    private lazy var diariesDataSource = makeDiariesDataSource()
    private lazy var petsDataSource = makePetsDataSource()

    deinit {
        print("DiaryViewController DIE")
    }

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
        diariesCollectionView.collectionViewLayout = createLayout(type: .grid)
        selectedPetsCollectionView.allowsMultipleSelection = true
        self.navigationController?.navigationBar.tintColor = UIColor(named: "main")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Filter"), style: .done, target: self, action: #selector(switchShowList))

        statusLabel.isHidden = false
        statusLabel.text = "翻閱日記中..."
        statusImage.isHidden = false
        statusImage.image = UIImage(named: "LoadDiary")

        diaryWallViewModel.showingDiaries.bind {  [weak self] diaries in

            var diaryItems = [Item]()

            let showUserPet = self?.userPetIds ?? [String]()

            diaries.forEach { diary in
                if showUserPet.contains(diary.petId) {
                    diaryItems.append(Item.diary(diary))
                }
            }
            self?.diaries = diaryItems

            if diaryItems.count != 0 {
                self?.statusLabel.isHidden = true
                self?.statusImage.isHidden = true

            } else {
                self?.statusLabel.isHidden = false
                self?.statusLabel.text = "尚未新增毛小孩日記唷！"
                self?.statusImage.image = UIImage(named: "NoDiary")
                self?.statusImage.isHidden = false
            }

        }

        diaryWallViewModel.getDataFailure = {

                self.statusLabel.text = "無法取得毛小孩日記！ 請確認網路連線狀態"
                self.statusImage.image = UIImage(named: "NoDiary")
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.navigationController?.navigationBar.backgroundColor = .white

        if showSelectedPetsCollectionView {
            self.selectedPetsCollectionView.isHidden = false

        } else {
            self.selectedPetsCollectionView.isHidden = true
            
        }
        diaryWallViewModel.fetchDiary()
        fetchData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = .clear
    }

    @objc func creatDiary() {

            let storyboard = UIStoryboard(name: "Diary", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "CreateDiaryViewController") as? CreateDiaryViewController else { return }
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor: UIColor(named: "main") ?? .orange]
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

    func fetchData() {

        FirebaseManager.shared.fetchPets(petIds: userPetIds) { result in

            switch result {

            case .success(let pets):

                var defaultShowingPetsId = [String]()
                var petsDataItem = [Item]()
                pets.forEach { pet in
                    defaultShowingPetsId.append(pet.petId)
                    petsDataItem.append(Item.pet(pet))
                    print("Pet = \(pet)")
                }
                self.userPetsData = petsDataItem
                self.showPets = defaultShowingPetsId

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
                cell.selectBackground.layer.borderColor = UIColor.white.cgColor
                cell.selectBackground.layer.borderWidth = 3
            }
        }
    }
    
    // MARK: - diariesCollectionViewCompositionLayout

    func createLayout(type: LayoutType) -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection in

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

extension DiaryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == selectedPetsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor.white.cgColor
            cell.selectBackground.layer.borderWidth = 3

            guard let petId = cell.petId else { return }
            if showPets.contains(petId) {
                return
            } else {
                showPets.append(petId)
            }

        } else {

            let storyboard = UIStoryboard(name: "Diary", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
            controller.viewModel = DetailViewModel(from: diaries[indexPath.row].diary!)
            self.navigationController?.show(controller, sender: nil)

        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == selectedPetsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor.white.cgColor
            cell.selectBackground.layer.borderWidth = 0

            guard let petId = cell.petId else { return }

            if let index = showPets.firstIndex(of: petId) {
                showPets.remove(at: index)
            }

        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard scrollView.contentOffset.y > 0 else { return }

        if (self.lastContentOffset >= scrollView.contentOffset.y) {

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {

                self.petsTopConstraint.constant = 0
                self.selectedPetsCollectionView.alpha = 1
                self.view.layoutIfNeeded()
            }

        } else if (self.lastContentOffset < scrollView.contentOffset.y) {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {

                self.petsTopConstraint.constant = -70
                self.selectedPetsCollectionView.alpha = 0
                self.view.layoutIfNeeded()

            }
        }

        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}
