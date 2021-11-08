//
//  AddNewItemTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit

class AddNewItemTableViewCell: UITableViewCell {
    @IBOutlet weak var cellCardBackGroundView: UIView!

    static let identifier = "AddNewItemTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        // Layout

        cellCardBackGroundView.layer.shadowColor = UIColor.gray.cgColor
        cellCardBackGroundView.layer.shadowOpacity = 0.2
        cellCardBackGroundView.layer.cornerRadius = 16
        cellCardBackGroundView.layer.shadowRadius = 4
        cellCardBackGroundView.backgroundColor = UIColor.white
        cellCardBackGroundView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
