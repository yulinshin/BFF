//
//  CommentTableViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/6.
//

import UIKit
import Foundation

class ChatListTableViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!

    var viewModel: ChatListVM?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

    }

    override func viewWillAppear(_ animated: Bool) {
        NetStatusManger.share.startMonitoring()
        viewModel?.filterBlockUser()
        self.tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        NetStatusManger.share.stopMonitoring()
    }

}


extension ChatListTableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0}
        return viewModel.showingList.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell", for: indexPath) as? ChatListTableViewCell else {
            return UITableViewCell() }

        guard let viewModel = viewModel else { return cell }
        
        cell.setup(viewModel: (viewModel.showingList.value[indexPath.row]))

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Message", bundle: nil)

        guard let controller = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }
        controller.viewModel = self.viewModel?.showingList.value[indexPath.row]
        self.navigationController?.show(controller, sender: nil)

    }
}

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var photImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    func setup(viewModel: ChatGroupVM) {

        viewModel.lastContent.bind { content in
            self.commentLabel.text = content
        }

        viewModel.lastCreatedTime.bind { date in
            self.dateLabel.text = date
        }

        viewModel.otherUserName.bind { name in
            self.nameLabel.text = name
        }

        viewModel.otherUsrPic.bind { url in
            self.photImageView.loadImage(url, placeHolder: UIImage(systemName: "person.fill"))
        }

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        photImageView.layer.cornerRadius = photImageView.bounds.height/2

    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
