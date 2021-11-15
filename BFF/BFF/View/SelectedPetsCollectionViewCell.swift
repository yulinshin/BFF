//
//  selectedPetsCollectionViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import UIKit

class SelectedPetsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var selectBackground: UIView!
    @IBOutlet weak var image: UIImageView!
    var petId: String?

    static let identifier = "SelectedPetsCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func congfigure(with viewModel: PhotoCellViewlModel, petId: String) {

        self.image.loadImage(viewModel.imageUrl)
        self.petId = petId

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        image.layer.cornerRadius = image.frame.height / 2
        image.clipsToBounds = true

        selectBackground.layer.cornerRadius = 52 / 2
        selectBackground.clipsToBounds = true

      }
}
