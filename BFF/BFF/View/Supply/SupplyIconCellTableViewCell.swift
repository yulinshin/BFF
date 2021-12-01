//
//  SupplyIconCellTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit

class SupplyIconCellTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var colorCollectionView: UICollectionView!

    @IBOutlet weak var stockProgressView: UIProgressView! {
        didSet {
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: { [unowned self] in
              stockProgressView.layoutIfNeeded()
            })
        }
    }
    @IBOutlet weak var itemCollectionView: UICollectionView!
    static let identifier = "SupplyIconCellTableViewCell"

    var colorArray = ["red", "orange", "yellow", "green", "blue", "purple"]
    var iconArray = ["Bag", "Food", "Fooeed", "Medice", "N", "water"]

    var iconNameCallback: ((_ iconName: String) -> Void)?

    var iconColorCallback: ((_ iconColor: String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        let diaryNib = UINib(nibName: "CubeCollectionViewCell", bundle: nil)
        colorCollectionView.register(diaryNib, forCellWithReuseIdentifier: CubeCollectionViewCell.identifier)
        itemCollectionView.register(diaryNib, forCellWithReuseIdentifier: CubeCollectionViewCell.identifier)
        iconImage.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension SupplyIconCellTableViewCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case colorCollectionView:
            return colorArray.count
        case itemCollectionView:
            return iconArray.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CubeCollectionViewCell.identifier, for: indexPath) as? CubeCollectionViewCell else { return UICollectionViewCell() }

        switch collectionView {
        case colorCollectionView:

            cell.iconImage.image = UIImage(named: "")
            cell.iconImage.backgroundColor = UIColor(named: colorArray[indexPath.row])
            cell.iconImage.layer.cornerRadius = 6
            return cell

        case itemCollectionView:

            cell.iconImage.image = UIImage(named: iconArray[indexPath.row])
            cell.iconImage.backgroundColor = .gray
            cell.iconImage.layer.cornerRadius = 6
            return cell

        default:
            return cell
        }

    }

}

extension SupplyIconCellTableViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

            guard let cell = collectionView.cellForItem(at: indexPath) as? CubeCollectionViewCell else { return }
        cell.background.layer.borderColor = UIColor.mainColor.cgColor
        cell.background.layer.borderWidth = 2
        cell.background.layer.cornerRadius = 8

        switch collectionView {

        case colorCollectionView:

            iconColorCallback?(colorArray[indexPath.row])

        case itemCollectionView:

            iconNameCallback?( iconArray[indexPath.row])

        default:
            return
        }

    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? CubeCollectionViewCell else { return }
        cell.background.layer.borderColor = UIColor.mainColor.cgColor
    cell.background.layer.borderWidth = 0

    }

}
