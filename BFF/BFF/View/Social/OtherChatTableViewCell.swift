//
//  OtherChatTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import UIKit

class OtherChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var chatBubbleContent: UILabel!
    
    @IBOutlet weak var chatView: UIView!

    var identifier = "OtherChatTableViewCell"

    var viewModel: ChatVM?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatView.layer.cornerRadius = 10
        chatView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(with otherUserPic: String) {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.content.bind { content in
            self.chatBubbleContent.text = content
        }
        self.profileImg.loadImage(otherUserPic)

    }
    
}
