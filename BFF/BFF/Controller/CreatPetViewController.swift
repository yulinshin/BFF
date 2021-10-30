//
//  CreatPetViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/20.
//

import UIKit

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
        petInfoTableView.reloadData()
    }


    @objc func updatePet() {

        guard let image = petImage.image else { return }

        viewModel.upDatePetToDB(image: image) { result in

            switch result {

            case .success(let message):

                print(message)
                self.dismiss(animated: true, completion: nil)

            case .failure(let error):
                print("fetchData.failure\(error)")

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

            cell.callback = { text in
                self.viewModel.updateData(name: text)
            }

        case "品種" :

            viewModel.type.bind { type in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = type

            }

            cell.callback = { text in
                self.viewModel.updateData(type: text)
            }

        case "生日" :

            cell.creatDatePicker()

            viewModel.birthday.bind { birthday in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = birthday

            }

            cell.callback = { text in
                self.viewModel.updateData(birthday: text)
            }

        case "體重" :

            viewModel.weight.bind { weight in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = "\(weight)"

            }

            cell.callback = { text in
                self.viewModel.updateData(weight: text)
            }

        case "體重單位" :

            viewModel.weightUnit.bind { weightUnit in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = weightUnit
                cell.creatPicker(pickerData: ["kg", "g"])

            }

            cell.callback = { text in
                self.viewModel.updateData(weightUnit: text)
            }

        case "性別" :

            viewModel.gender.bind { gender in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = gender
                cell.creatPicker(pickerData: ["boy", "girl"])

            }

            cell.callback = { text in
                self.viewModel.updateData(gender: text)
            }

        case "晶片" :

            viewModel.chipId.bind { chipId in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = chipId

            }

            cell.callback = { text in
                self.viewModel.updateData(chipId: text)
            }

        case "備註" :

            cell.configur(cellStyle: .more, title: fields[indexPath.row] )

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

                self.navigationController?.show(controller, sender: nil)

            }

        default:
            return cell
        }

        return cell
    }

}
