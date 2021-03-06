//
//  UserDiaries+DiffDataSource.swift
//  BFF
//
//  Created by yulin on 2021/10/22.
//

import Foundation
import UIKit

extension UserDiariesViewController {

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

        let dataSource = DataSource(collectionView: diariesCollectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DairyPhotoCell.identifier, for: indexPath) as? DairyPhotoCell

            guard let imageStr = item.diary?.images.first?.url else { return cell }
            cell?.configure(with: PhotoCellViewModel(with: imageStr))

            return cell
        }

        return dataSource

    }

}
