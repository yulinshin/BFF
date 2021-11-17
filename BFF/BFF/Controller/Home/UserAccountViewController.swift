//
//  UserAccountViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/9.
//

import UIKit

class UserAccountTableViewController: UITableViewController {


    var userInFo = ["姓名", "Email"]

    var user: User?

    var selectedImage: UIImage? {
        didSet{
            tableView.reloadData()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(saveUserInfo))

        // Do any additional setup after loading the view.
    }


    @objc func saveUserInfo() {

        guard let user = user else {
            return
        }

        guard let selectedImage = selectedImage else {

            FirebaseManager.shared.updateUserInfo(user: user) { result in

                switch result {

                case .success(let message):
                    print(message)

                case.failure(let error):
                    print(error)
                }
            }

            return


            }

        FirebaseManager.shared.updateUserInfo(user: user, newimage: selectedImage) { result in

            switch result {

            case .success(let message):
                print(message)

            case.failure(let error):
                print(error)
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

            cell.userPicImageVIew.image = selectedImage

            return  cell

        } else{

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as? UserInfoCell else { return UITableViewCell()}

            cell.selectionStyle = .none
            cell.titleLabel.text = userInFo[indexPath.row]

            switch indexPath.row {

            case 0:
                cell.contentTextField.text = user.userName

            case 1:
                cell.contentTextField.text = user.email

            default:
                print("outOfRange")
            }
            return  cell

        }





        return UITableViewCell()

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {

            return 1

        } else{


            return userInFo.count

        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }


}


class UserPicCell: UITableViewCell {


    @IBOutlet weak var userPicImageVIew: UIImageView!

    @IBOutlet weak var addIcon: UIImageView!

    override class func awakeFromNib() {

    }

    var didTapChangeUserPicButton: (() -> ())?

    func setup(userPic: String){

        userPicImageVIew.loadImage(userPic, placeHolder: UIImage(named: "UserPicPalceHolder"))
        addIcon.backgroundColor = .white
        addIcon.layer.borderWidth = 2
        addIcon.layer.borderColor = UIColor.white.cgColor
        addIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePic)) )
        addIcon.isUserInteractionEnabled = true

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userPicImageVIew.layer.cornerRadius = userPicImageVIew.bounds.height / 2
        addIcon.layer.cornerRadius = addIcon.bounds.height/2
    }

    @objc func changePic() {
        self.didTapChangeUserPicButton?()

    }


}


class UserInfoCell: UITableViewCell {

    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!

    override class func awakeFromNib() {

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

        var slectedImageFromPicker: UIImage?

        if let editedImage = info[.editedImage] as? UIImage {
            slectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            print(originalImage.size)
            slectedImageFromPicker = originalImage
        }

        if let selectedImage = slectedImageFromPicker {

            self.selectedImage = selectedImage

        }
        picker.dismiss(animated: true, completion: nil)
    }
}
