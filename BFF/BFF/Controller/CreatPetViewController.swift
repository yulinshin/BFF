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
        "Name",
        "Type",
        "Birthday",
        "Weight",
        "WeightUnit",
        "Gender",
        "ChipId",
        "Note"
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

    }

    override func viewWillAppear(_ animated: Bool) {

        switch presentMode {

        case .read:

            self.navigationItem.title = "My Pet"

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(savePet))

            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .done, target: self, action: #selector(cancel))

        case .edit:

            self.navigationItem.title = "Edit Pet"

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(updatePet))

            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))

        case .creat:

            self.navigationItem.title = "Creat Pet"

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(savePet))

            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))


        case .none:
            return
        }


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

        viewModel.creatPet(image: image) { result in

            switch result {

            case .success(let message):

                print(message)
                self.dismiss(animated: true, completion: nil)

            case .failure(let error):
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

        case "Name" :

            viewModel.name.bind { name in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = name

            }

            cell.callback = { text in
                self.viewModel.updateData(name: text)
            }

        case "Type" :

            viewModel.type.bind { type in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = type

            }

            cell.callback = { text in
                self.viewModel.updateData(type: text)
            }

        case "Birthday" :

            cell.creatDatePicker()

            viewModel.birthday.bind { birthday in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = birthday

            }

            cell.callback = { text in
                self.viewModel.updateData(birthday: text)
            }

        case "Weight" :

            viewModel.weight.bind { weight in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = "\(weight)"

            }

            cell.callback = { text in
                self.viewModel.updateData(weight: text)
            }

        case "WeightUnit" :

            viewModel.weightUnit.bind { weightUnit in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = weightUnit
                cell.creatPicker(pickerData: ["kg", "g"])

            }

            cell.callback = { text in
                self.viewModel.updateData(weightUnit: text)
            }

        case "Gender" :

            viewModel.gender.bind { gender in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = gender
                cell.creatPicker(pickerData: ["boy", "girl"])

            }

            cell.callback = { text in
                self.viewModel.updateData(gender: text)
            }

        case "ChipId" :

            viewModel.chipId.bind { chipId in

                cell.configur(cellStyle: .textfield, title: self.fields[indexPath.row] )
                cell.textField.text = chipId

            }

            cell.callback = { text in
                self.viewModel.updateData(chipId: text)
            }

        case "Note" :

            cell.configur(cellStyle: .more, title: fields[indexPath.row] )

            cell.moreButtonTap = {

                let storyboard = UIStoryboard(name: "Pet", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "NoteViewController") as? NoteViewController else { return }
                self.viewModel.note.bind { text in
                    controller.note = text
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
