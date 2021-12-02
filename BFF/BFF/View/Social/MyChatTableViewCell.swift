

import UIKit

class MyChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatView: UIView!

    @IBOutlet weak var chatBubbleContent: UILabel!
    
    var identifier = "MyChatTableViewCell"

    var viewModel: ChatVM?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatView.layer.cornerRadius = 10
        chatView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        self.selectionStyle = .none

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup() {
        guard let viewModel = viewModel else {
            return
        }

        viewModel.content.bind { content in
            self.chatBubbleContent.text = content
        }

    }
    
}
