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

    var selcetedPets = [String]()

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
        cell.congfigure(with: PhotoCellViewlModel(with: imageStr ?? ""), petId: petId)
        if selcetedPets.contains(petId){
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            cell.isSelected = true
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
        cell.selectBackground.layer.borderColor = UIColor(named: "main")?.cgColor
        cell.selectBackground.layer.borderWidth = 2

        guard let petId = cell.petId else { return }
        if selcetedPets.contains(petId) {
            return
        } else {
            selcetedPets.append(petId)
            callback?(selcetedPets)
        }

    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor(named: "main")?.cgColor
            cell.selectBackground.layer.borderWidth = 0

            guard let petId = cell.petId else { return }

            if let index = selcetedPets.firstIndex(of: petId) {
                selcetedPets.remove(at: index)
                callback?(selcetedPets)
            }

    }
}
