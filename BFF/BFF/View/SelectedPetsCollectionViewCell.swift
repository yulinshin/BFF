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

      }
    override func layoutSublayers(of layer: CALayer) {

        selectBackground.layer.cornerRadius = selectBackground.bounds.height / 2
        selectBackground.clipsToBounds = true
        image.layer.cornerRadius = image.bounds.height / 2
        image.clipsToBounds = true

        if self.isSelected {
            selectBackground.layer.borderColor = UIColor(named: "main")?.cgColor
            selectBackground.layer.borderWidth = 2
        }else{
            selectBackground.layer.borderColor = UIColor(named: "main")?.cgColor
            selectBackground.layer.borderWidth = 0
        }

    }
    
}
