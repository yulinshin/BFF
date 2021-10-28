//
//  AddNewItemTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit

class AddNewItemTableViewCell: UITableViewCell {
    @IBOutlet weak var cellCardBackGroundVIew: UIView!

    static let identifier = "AddNewItemTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        // Layout

        cellCardBackGroundVIew.layer.shadowColor = UIColor.gray.cgColor
        cellCardBackGroundVIew.layer.shadowOpacity = 0.2
        cellCardBackGroundVIew.layer.cornerRadius = 16
        cellCardBackGroundVIew.layer.shadowRadius = 4
        cellCardBackGroundVIew.backgroundColor = UIColor.white
        cellCardBackGroundVIew.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
