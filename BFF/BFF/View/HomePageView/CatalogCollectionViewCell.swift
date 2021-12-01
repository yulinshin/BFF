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

    static var identifier = "CatalogCollectionViewCell"

    func setup(title: String, iconName: String ) {
        iconBackgroundView.layer.shadowColor = UIColor.mainColor.cgColor
        iconImageView.layer.shadowOffset = CGSize(width: 1, height: 1)
        iconImageView.layer.cornerRadius = 10
        titleLabel.text = title
        iconImageView.image = UIImage(named: iconName)

    }

    override func layoutSubviews() {
        iconBackgroundView.backgroundColor = .white
        iconBackgroundView.layer.cornerRadius = 10
        iconBackgroundView.layer.shadowColor = UIColor.mainColor.cgColor
        iconBackgroundView.layer.shadowOffset = CGSize(width: 1, height: 1)
        iconBackgroundView.layer.shadowOpacity = 0.5
        iconBackgroundView.layer.shadowRadius = 2
      }
    
}
