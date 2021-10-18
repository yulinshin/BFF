//
//  CatalogCollectionViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import UIKit

class CatalogCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    func setup(title: String, iconName: String ) {
        iconBackgroundView.layer.shadowColor = UIColor.orange.cgColor
        iconImageView.layer.shadowOffset = CGSize(width: 1, height: 1)
        titleLabel.text = title
        iconImageView.image = UIImage(named: iconName)

    }
}
