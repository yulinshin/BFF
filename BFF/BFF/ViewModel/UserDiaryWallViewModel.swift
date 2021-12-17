//
//  UserDiaryWallViewModel.swift
//  BFF
//
//  Created by yulin on 2021/12/3.
//

import Foundation
import UIKit

class UserDiaryWallViewModel {

    var petIds: [String]?
    var diaries = Box([Diary]())
    var showingDiaries = Box([Diary]())
    var diariess = [Item]() {
        didSet {
            applySnapshot()
        }
    }
    lazy var diariesDataSource = makeDiariesDataSource()
    var didUpDateData: (() -> Void)?
    var noMoreData: (() -> Void)?
    var getDataFailure: (() -> Void)?
    weak var collectionView: UICollectionView?
    func fetchUserDiaries(isFetchMore: Bool = false) {

        if !isFetchMore {
            FirebaseManager.shared.userDiaryPagingLastDoc = nil
        }

        FirebaseManager.shared.fetchDiaries { result in

            switch result {

            case .success(let diaries):

                if  diaries.count == 0 {
                    self.noMoreData?()
                } else {
                    if isFetchMore {
                        self.diaries.value += diaries
                    } else {
                        self.diaries.value = diaries
                    }

                    if let petIds = self.petIds {

                        self.diaries.value = self.diaries.value.filter({ diary in
                            if petIds.contains(diary.petId) {
                                return true
                            } else { return false }
                        })

                    }

                    self.updatePetData()
                }

            case.failure(let error):

                print(error)

            }
        }
    }

    func updatePetData() {
        let group: DispatchGroup = DispatchGroup()
        for (index, diary) in diaries.value.enumerated() {
            group.enter()
            print("group: enter")
            FirebaseManager.shared.fetchPet(petId: diary.petId) { result in

                switch result {

                case.success(let pet):

                    self.diaries.value[index].petName = pet.name
                    self.diaries.value[index].petThumbnail = pet.petThumbnail ?? Pic(url: "", fileName: "")
                    group.leave()
                    print("group: leave")

                case.failure(let error):
                    group.leave()
                    print("group:leave")
                        print(error)
                }

            }

        }

        group.notify(queue: DispatchQueue.main) {
            print("group: Notify")
            self.showingDiaries.value = self.diaries.value
            self.makeItems()
        }
    }

    func makeItems() {
        var diaryItems = [Item]()
        showingDiaries.value.forEach { diary in
                diaryItems.append(Item.diary(diary))
        }
        self.diariess = diaryItems
        self.applySnapshot()
    }
}

extension UserDiaryWallViewModel {

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

    func makeDiariesDataSource() -> DataSource {

        guard let collectionView = collectionView else { fatalError() }
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DairyPhotoCell.identifier, for: indexPath) as? DairyPhotoCell

            guard let imageStr = item.diary?.images.first?.url else { return cell }
            cell?.configure(with: PhotoCellViewModel(with: imageStr))

            return cell
        }

        return dataSource

    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var diariesSnapshot = Snapshot()
        diariesSnapshot.appendSections([.all])
        diariesSnapshot.appendItems(diariess, toSection: .all)
        diariesDataSource.apply(diariesSnapshot, animatingDifferences: false)
        didUpDateData?()
    }

}
