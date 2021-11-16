//
//  CreatPetViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/20.
//

import UIKit
import SwiftUI

class CreatPetViewController: UIViewController {

    @IBOutlet weak var petImage: UIImageView!

    @IBOutlet weak var petInfoTableView: UITableView!

    var viewModel = CreatPetViewModel()

    var fields  = [
        "名字",
        "品種",
        "生日",
        "體重",
        "體重單位",
        "性別",
        "晶片",
        "備註"
    ]

    enum PresentMode {

        case read

        case edit

        case creat

    }

    var presentMode: PresentMode?

    override func viewDidLoad() {
        super.viewDidLoad()
        petInfoTableView.delegate = self
        petInfoTableView.dataSource = self

        let petInfoNib = UINib(nibName: "PetInfoTableTableViewCell", bundle: nil)
        petInfoTableView.register(petInfoNib, forCellReuseIdentifier: PetInfoTableTableViewCell.identifier)

        // ImagePicker
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectedPetImage))
        petImage.addGestureRecognizer(tapGR)
        petImage.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.tintColor = UIColor(named: "main")

        petImage.layer.cornerRadius = petImage.frame.height/2
        petImage.clipsToBounds = true



    }

    override func viewWillAppear(_ animated: Bool) {


        switch presentMode {

        case .read:

            self.navigationItem.title = "\(viewModel.name.value)"


            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "編輯", style: .done, target: self, action: #selector(coverToEditMode))

            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .done, target: self, action: #selector(cancel))


        case .edit:

            self.navigationItem.title = "\(viewModel.name.value)"

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(updatePet))

            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancel))

        case .creat:

            self.navigationItem.title = "新增毛小孩"

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "新增", style: .done, target: self, action: #selector(savePet))

            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancel))


        case .none:
            return
        }


    }

    @objc func coverToEditMode(){
        self.presentMode = .edit
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(self.updatePet))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(self.cancel))
        petInfoTableView.reloadData()
    }


    @objc func updatePet() {

        ProgressHUD.show()

        guard let image = petImage.image else { return }

        viewModel.upDatePetToDB(image: image) { result in

            ProgressHUD.dismiss()

            switch result {

            case .success(let message):
                print(message)
                self.navigationController?.popViewController(animated: true)
                ProgressHUD.showSuccess(text: "修改成功")

            case .failure(let error):
                print("fetchData.failure\(error)")
                ProgressHUD.showFailure(text: "修改失敗")

            }

        }

    }


    @objc func savePet() {

        guard let image = petImage.image else { return }

        ProgressHUD.show()
        

        viewModel.creatPet(image: image) { result in

            ProgressHUD.dismiss()

            switch result {

            case .success(let message):
                ProgressHUD.showSuccess(text: "建立成功")

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.dismiss(animated: true, completion: nil)
                      }
                print(message)


            case .failure(let error):

                ProgressHUD.showFailure(text: "建立失敗")
                print("fetchData.failure\(error)")

            }

        }
    }


    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)

    }
}

extension CreatPetViewController: UITableViewDelegate {

}

extension CreatPetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: PetInfoTableTableViewCell.identifier) as? PetInfoTableTableViewCell else { return UITableViewCell() }
        

        switch fields[indexPath.row] {

        case "名字" :

            viewModel.name.bind { name in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = name

            }
            cell.button.isHidden = true

            cell.callback = { text in
                self.viewModel.updateData(name: text)
            }

        case "品種" :

            viewModel.type.bind { type in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = type

            }
            cell.button.isHidden = true
            cell.callback = { text in
                self.viewModel.updateData(type: text)
            }

        case "生日" :

            cell.creatDatePicker()

            viewModel.birthday.bind { birthday in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = birthday

            }
            cell.button.isHidden = true
            cell.callback = { text in
                self.viewModel.updateData(birthday: text)
            }

        case "體重" :

            viewModel.weight.bind { weight in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = "\(weight)"
                cell.textField.keyboardType = .numbersAndPunctuation

            }
            cell.button.isHidden = true
            cell.callback = { text in
                self.viewModel.updateData(weight: text)
            }

        case "體重單位" :

            viewModel.weightUnit.bind { weightUnit in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = weightUnit
                cell.creatPicker(pickerData: ["", "kg", "g"])

            }
            cell.button.isHidden = true
            cell.callback = { text in
                self.viewModel.updateData(weightUnit: text)
            }

        case "性別" :

            viewModel.gender.bind { gender in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = gender
                cell.creatPicker(pickerData: ["", "boy", "girl"])

            }
            cell.button.isHidden = true
            cell.callback = { text in
                self.viewModel.updateData(gender: text)
            }

        case "晶片" :

            viewModel.chipId.bind { chipId in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = chipId

            }
            cell.button.isHidden = true
            cell.callback = { text in
                self.viewModel.updateData(chipId: text)
            }

        case "備註" :

            cell.configur(cellStyle: .more, title: fields[indexPath.row] )
            cell.button.isHidden = false
            cell.textField.isHidden = true
            cell.moreButtonTap = {

                let storyboard = UIStoryboard(name: "Pet", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "NoteViewController") as? NoteViewController else { return }
                self.viewModel.note.bind { text in
                    controller.note = self.viewModel.name.value
                    controller.petsName = (self.viewModel.name.value)
                    controller.callBack = { [weak self] text in
                        self?.viewModel.updateData(note: text)
                    }
                }

                if self.presentMode == .read {
                    controller.mode = .read
                } else if self.presentMode == .edit {
                    controller.mode = .edit
                }else {
                    controller.mode = .creat
                }


                self.navigationController?.show(controller, sender: nil)

            }

        default:
            return cell
        }

        if presentMode == .read {
            self.viewModel.petThumbnail.bind { url in
                self.petImage.isUserInteractionEnabled = false
                self.petImage.loadImage(url, placeHolder: UIImage())
            }
            cell.textField.isUserInteractionEnabled = false
        } else if presentMode == .edit {
            self.viewModel.petThumbnail.bind { url in
                self.petImage.isUserInteractionEnabled = true
                self.petImage.loadImage(url, placeHolder: UIImage())
            }
            cell.textField.isUserInteractionEnabled = true
        } else {
            cell.textField.isUserInteractionEnabled = true
        }

        return cell
    }

}
