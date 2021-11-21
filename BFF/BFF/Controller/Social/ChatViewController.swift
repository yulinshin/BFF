//
//  CustomerServiceViewController.swift
//  STYLiSH
//
//  Created by Allie T on 2021/10/3.
//  Copyright © 2021 WU CHIH WEI. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChatViewController: UIViewController {

    var viewModel: ChatGroupVM?

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self

        tableView.delegate = self

        tableView.separatorStyle = .none
        messageTextField.delegate = self

        let myChatNib = UINib(nibName: "MyChatTableViewCell", bundle: nil)
        tableView.register(myChatNib, forCellReuseIdentifier: "MyChatTableViewCell")

        let otherChatNib = UINib(nibName: "OtherChatTableViewCell", bundle: nil)
        tableView.register(otherChatNib, forCellReuseIdentifier: "OtherChatTableViewCell")

        viewModel?.didChatUpdate = {
            self.tableView.reloadData()
        }

        viewModel?.otherUserName.bind(listener: { name in
            self.title = name
        })

        self.navigationController?.navigationBar.tintColor = UIColor(named: "main")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "．．．", style: .done, target: self, action: #selector(showSetting))

    }

   @objc func showSetting() {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        var action = UIAlertAction()

        action = UIAlertAction(title: "封鎖並檢舉此寵物的主人", style: .default, handler: { action in
            self.blockUser(userId: self.viewModel?.otherUserId.value ?? "")
        })


        // Block PetsId -> Only show on other's Diary
        alertController.addAction(action)

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))

            self.present(alertController, animated: true, completion: nil)

    }

    func blockUser(userId: String) {

        FirebaseManager.shared.updateCurrentUserBlockUsers(blockUserId: userId) { result in

            switch result {

            case .success(let message):
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print(error)

            }

        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        
        guard let message = messageTextField.text,
              let groupId = self.viewModel?.groupId.value,
        let otherUserId = self.viewModel?.otherUserId.value else {
            return

        }

        FirebaseManager.shared.sendMessage(reciverId: otherUserId, groupId: groupId, content: message)

        messageTextField.text = ""

    }
}


// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.chatVMs.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = UITableViewCell()



        if viewModel?.chatVMs.value[indexPath.row].userId.value == FirebaseManager.shared.userId {

                guard let myCell = tableView.dequeueReusableCell(
                    withIdentifier: "MyChatTableViewCell",
                    for: indexPath) as? MyChatTableViewCell else { return cell}
            myCell.viewModel = viewModel?.chatVMs.value[indexPath.row]
                myCell.setup()
                cell = myCell

            } else {

                guard let otherCell = tableView.dequeueReusableCell(
                    withIdentifier: "OtherChatTableViewCell",
                    for: indexPath) as? OtherChatTableViewCell else { return  cell}
                otherCell.viewModel = viewModel?.chatVMs.value[indexPath.row]
                otherCell.setup(with: viewModel?.otherUserId.value ?? "")
                cell = otherCell

            }



        return cell
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}


extension ChatViewController: UITableViewDelegate {
    
}


extension ChatViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {

        }

        func textFieldDidEndEditing(_ textField: UITextField) {

        }

}
