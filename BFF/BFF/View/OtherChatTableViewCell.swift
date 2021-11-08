//
//  CustomerServiceTableViewCell.swift
//  STYLiSH
//
//  Created by Allie T on 2021/10/3.
//  Copyright © 2021 WU CHIH WEI. All rights reserved.
//

import UIKit

class OtherChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var chatBubbleContent: UILabel!
    
    @IBOutlet weak var chectView: UIView!

    var identifier = "OtherChatTableViewCell"

    var viewModel: ChatViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        chectView.layer.cornerRadius = 10
        chectView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(){
        guard let viewModel = viewModel else {
            return
        }

        viewModel.sender.bind { sender in
            self.profileImg.loadImage(sender)
        }

        viewModel.content.bind { content in
            self.chatBubbleContent.text = content
        }

    }
    
}
