//
//  PetHealthCardListTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/31.
//

import UIKit

class PetHealthCardListTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var petImage: UIImageView!

    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var birthdayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var didTapDeleteButton: (() -> Void)?
    var didTapMoreInfoButton: (() -> Void)?

    static var identifier = "PetHealthCardListTableViewCell"

    func configure() {
        backGroundView.layer.shadowColor = UIColor.gray.cgColor
        backGroundView.layer.shadowOpacity = 0.2
        backGroundView.layer.cornerRadius = 16
        backGroundView.layer.shadowRadius = 4
        backGroundView.backgroundColor = UIColor.white
        backGroundView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        petImage.layer.cornerRadius = 16
        healthButton.layer.cornerRadius = 10

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func moreInfo(_ sender: Any) {
        didTapMoreInfoButton?()
    }
    @IBAction func deleteButton(_ sender: Any) {
        didTapDeleteButton?()

    }

}
