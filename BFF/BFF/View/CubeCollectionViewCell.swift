//
//  CubeCollectionViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit

class CubeCollectionViewCell: UICollectionViewCell {


    static let identifier = "CubeCollectionViewCell"

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var iconImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
