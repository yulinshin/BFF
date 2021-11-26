//
//  SupplyPetsTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit

class SupplyPetsTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    static let identifier = "SupplyPetsTableViewCell"

    var selectedPets = [String]()

    var userPetsData = [Pet]() {
        didSet {
            print("userPetsData:\(userPetsData.count)")
            collectionView.reloadData() }
    }

    var callback: ((_ pets: [String]) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self

        let petNib = UINib(nibName: "SelectedPetsCollectionViewCell", bundle: nil)
        collectionView.register(petNib, forCellWithReuseIdentifier: SelectedPetsCollectionViewCell.identifier)

        collectionView.allowsMultipleSelection = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension SupplyPetsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        userPetsData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // swiftlint:disable:next line_length
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedPetsCollectionViewCell.identifier, for: indexPath) as? SelectedPetsCollectionViewCell else { return UICollectionViewCell()}

        let imageStr = userPetsData[indexPath.row].petThumbnail?.url
        let petId = userPetsData[indexPath.row].petId
        cell.configure(with: PhotoCellViewModel(with: imageStr ?? ""), petId: petId)
        
        if selectedPets.contains(petId) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            cell.isSelected = true
            cell.selectBackground.layer.borderColor = UIColor.mainColor.cgColor
            cell.selectBackground.layer.borderWidth = 2
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
        cell.selectBackground.layer.borderColor = UIColor.mainColor.cgColor
        cell.selectBackground.layer.borderWidth = 2

        guard let petId = cell.petId else { return }
        if selectedPets.contains(petId) {
            return
        } else {
            selectedPets.append(petId)
            callback?(selectedPets)
        }

    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor.mainColor.cgColor
            cell.selectBackground.layer.borderWidth = 0

            guard let petId = cell.petId else { return }

            if let index = selectedPets.firstIndex(of: petId) {
                selectedPets.remove(at: index)
                callback?(selectedPets)
            }

    }
}
