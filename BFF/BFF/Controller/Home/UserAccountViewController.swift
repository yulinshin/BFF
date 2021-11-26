//
//  UserAccountViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/9.
//

import UIKit
import AVFoundation

class UserInfoViewModel {

    var name = Box("")
    var email = Box("")

    init(user: User){
        self.name.value = user.userName
        self.email.value = user.email
    }

}

class UserAccountTableViewController: UITableViewController {

    var userInFo = ["姓名", "Email"]
    var user: User?
    var viewModel: UserInfoViewModel?

    var selectedImage: UIImage? {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(saveUserInfo))
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        FirebaseManager.shared.fetchUserInfo { result in
            switch result {

            case.success( let user ):

                self.user = user
                self.viewModel = UserInfoViewModel(user: user)
                self.tableView.reloadData()

            case.failure( let error ):
                print(error)

            }
        }
    }


    @objc func saveUserInfo() {

        ProgressHUD.show()


        guard let user = user else {
            return
        }

        var newUser = user
        newUser.email = viewModel?.email.value ?? user.email
        newUser.userName = viewModel?.name.value ?? user.userName
        print("******\(newUser)")

        guard let selectedImage = selectedImage else {

            FirebaseManager.shared.updateUserInfo(user: newUser, newImage: nil) { result in

                ProgressHUD.dismiss()

                switch result {

                case .success(let message):
                    print(message)
                    ProgressHUD.showSuccess(text: "修改成功")
                    self.dismiss(animated: true, completion: nil)
                case.failure(let error):
                    print(error)
                    ProgressHUD.showFailure(text: "修改失敗")
                }
            }

            return

            }

        FirebaseManager.shared.updateUserInfo(user: newUser, newImage: selectedImage) { result in

            ProgressHUD.dismiss()

            switch result {

            case .success(let message):
                print(message)
                ProgressHUD.showSuccess(text: "修改成功")
                self.dismiss(animated: true, completion: nil)
            case.failure(let error):
                print(error)
                ProgressHUD.showFailure(text: "修改失敗")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let user = user else {
            return UITableViewCell()
        }

        if indexPath.section == 0 {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserPicCell", for: indexPath) as? UserPicCell else { return UITableViewCell()}
            cell.selectionStyle = .none
            cell.didTapChangeUserPicButton = {
                self.handleSelectedUserImage()
            }
            cell.selectionStyle = .none

            guard let selectedImage = selectedImage else {
                cell.setup(userPic: user.userThumbNail?.url ?? "" )
                return cell
            }

            cell.userPicImageView.image = selectedImage

            return  cell

        } else {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as? UserInfoCell else { return UITableViewCell()}

            cell.selectionStyle = .none
            cell.titleLabel.text = userInFo[indexPath.row]

            switch indexPath.row {

            case 0:

                viewModel?.name.bind(listener: { name in
                    cell.contentTextField.text = name
                })
                cell.contentTextField.delegate = cell
                cell.callback = { text in
                    self.viewModel?.name.value = text
                }

            case 1:
                viewModel?.email.bind(listener: { email in
                    cell.contentTextField.text = email
                })
                cell.callback = { text in
                    self.viewModel?.email.value = text
                }
                cell.contentTextField.delegate = cell

            default:
                print("outOfRange")
            }
            return  cell

        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {

            return 1

        } else {

            return userInFo.count

        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

}

class UserPicCell: UITableViewCell {

    @IBOutlet weak var userPicImageView: UIImageView!

    @IBOutlet weak var addIcon: UIImageView!

    override class func awakeFromNib() {

    }

    var didTapChangeUserPicButton: (() -> ())?

    func setup(userPic: String) {

        userPicImageView.loadImage(userPic, placeHolder: UIImage(systemName: "person.fill"))
        addIcon.backgroundColor = .white
        addIcon.layer.borderWidth = 2
        addIcon.layer.borderColor = UIColor.white.cgColor
        addIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePic)))
        addIcon.isUserInteractionEnabled = true

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userPicImageView.layer.cornerRadius = userPicImageView.bounds.height / 2
        addIcon.layer.cornerRadius = addIcon.bounds.height/2
    }

    @objc func changePic() {
        self.didTapChangeUserPicButton?()

    }


}


class UserInfoCell: UITableViewCell {

    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    var callback: ((_ text: String) -> Void)?
    override class func awakeFromNib() {
    }
}

extension UserInfoCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {

        guard let text = textField.text else { return }
        callback?(text)

    }

}

extension UserAccountTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func handleSelectedUserImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        var selectedImageFromPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            print(originalImage.size)
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            self.selectedImage = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
