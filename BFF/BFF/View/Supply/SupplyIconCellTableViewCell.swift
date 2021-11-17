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
    @IBOutlet weak var colorCollectionVew: UICollectionView!

    @IBOutlet weak var stockPrgressView: UIProgressView!
    @IBOutlet weak var itemCollecitonView: UICollectionView!
    static let identifier = "SupplyIconCellTableViewCell"

    var colorArray = ["red", "orange","yellow","green","blue","purple"]
    var iconArray = ["Bag","Food","Fooeed","Medice","N","water"]

    var iconNameCallback: ((_ iconName: String) -> Void)?

    var iconColorCallback: ((_ iconColor: String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        colorCollectionVew.delegate = self
        colorCollectionVew.dataSource = self
        itemCollecitonView.delegate = self
        itemCollecitonView.dataSource = self
        let diaryNib = UINib(nibName: "CubeCollectionViewCell", bundle: nil)
        colorCollectionVew.register(diaryNib, forCellWithReuseIdentifier: CubeCollectionViewCell.identifier)
        itemCollecitonView.register(diaryNib, forCellWithReuseIdentifier: CubeCollectionViewCell.identifier)
        iconImage.layer.cornerRadius = 20

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension SupplyIconCellTableViewCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case colorCollectionVew:
            return colorArray.count
        case itemCollecitonView:
            return iconArray.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {


        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CubeCollectionViewCell.identifier, for: indexPath) as? CubeCollectionViewCell else { return UICollectionViewCell() }

        switch collectionView {
        case colorCollectionVew:

            cell.iconImage.image = UIImage(named: "")
            cell.iconImage.backgroundColor = UIColor(named: colorArray[indexPath.row])
            cell.iconImage.layer.cornerRadius = 6
            return cell

        case itemCollecitonView:


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
        cell.background.layer.borderColor = UIColor(named: "main")?.cgColor
        cell.background.layer.borderWidth = 2
        cell.background.layer.cornerRadius = 8

        switch collectionView {

        case colorCollectionVew:

            iconColorCallback?(colorArray[indexPath.row])

        case itemCollecitonView:

            iconNameCallback?( iconArray[indexPath.row])

        default:
            return
        }

    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? CubeCollectionViewCell else { return }
    cell.background.layer.borderColor = UIColor(named: "main")?.cgColor
    cell.background.layer.borderWidth = 0

    }

}
