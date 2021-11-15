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

    var viewModel: ChatListViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        viewModel = ChatListViewModel(updateNotify: {
            self.tableView.reloadData()
        })

    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
    }


}



extension ChatListTableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0}
        return viewModel.showingUserList.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell", for: indexPath) as? ChatListTableViewCell else {
            return UITableViewCell() }

        guard let viewModel = viewModel else { return cell}
        cell.setup(viewModel: (viewModel.showingUserList.value[indexPath.row]))

        viewModel.showingUserList.value[indexPath.row].didGetData = {
            cell.nameLabel.text =  viewModel.showingUserList.value[indexPath.row].userName.value
            cell.photImageView.loadImage( viewModel.showingUserList.value[indexPath.row].userPic.value , placeHolder: UIImage(systemName: "person.fill"))
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Message", bundle: nil)

        guard let controller = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }
        controller.viewModel = self.viewModel?.showingUserList.value[indexPath.row]
        self.navigationController?.show(controller, sender: nil)


    }
}



class ChatListTableViewCell: UITableViewCell{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var photImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    func setup(viewModel: ChatGroupViewModel) {

        viewModel.lastMassage.bind { content in
            self.commentLabel.text = content
        }

        viewModel.lastMassageDate.bind { date in
            self.dateLabel.text = date
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

