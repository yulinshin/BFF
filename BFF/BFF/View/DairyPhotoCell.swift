//
//  CollectionViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import UIKit

class DairyPhotoCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!

    static let identifier = "DairyPhotoCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MVVM
    func configure(with viewModel: PhotoCellViewlModel) {
        image.loadImage(viewModel.imageUrl)
    }

}
