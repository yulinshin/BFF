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

    var fields  = [
        "Name",
        "Type",
        "Birthday",
        "Weight",
        "WeightUnit",
        "Gender",
        "ChipId",
        "Allergy",
        "Note",
    ]


    var pet = Pet(petId: "", name: "", userId: "", healthInfo: HealthInfo(allergy: "", birthday: "", chipId: "", gender: "boy", note: "", type: "", weight: 0, weightUnit: "kg") , petThumbnail: "")


    override func viewDidLoad() {
        super.viewDidLoad()
        petInfoTableView.delegate = self
        petInfoTableView.dataSource = self
    let petInfoNib = UINib(nibName: "PetInfoTableTableViewCell", bundle: nil)
        petInfoTableView.register(petInfoNib, forCellReuseIdentifier: PetInfoTableTableViewCell.identifier)
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectedPetImage))
        petImage.addGestureRecognizer(tapGR)
        petImage.isUserInteractionEnabled = true
    }



    @IBAction func creatPet(_ sender: Any) {
        
        print(pet)

        guard let image = petImage.image else {
                  return
              }
        FirebaseManager.shared.uploadDiaryPhoto(image: image, filePath: .petPhotos) { result in

            switch result {

            case .success(let urlString):

                self.pet.petThumbnail = urlString

                FirebaseManager.shared.creatPets(newPet: self.pet)


                self.navigationController?.dismiss(animated: true, completion: nil)


            case .failure(let error):
                print("fetchData.failure\(error)")

            }

        }

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

            cell.configur(cellStyle: .textfield, title: fields[indexPath.row] )
            cell.callback = { text in
                self.pet.name = text
            }


        case "Type" :

            cell.configur(cellStyle: .textfield, title: fields[indexPath.row] )

            cell.callback = { text in
                self.pet.healthInfo.type = text
            }

        case "Birthday" :


            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM/dd/yyyy"
            let str = dateFormatterPrint.string(from: Date())
            cell.configur(cellStyle: .textfield, title: fields[indexPath.row], button: str )
            cell.textField.textContentType = .dateTime

            cell.creatDatePicker()

            cell.callback = { text in
                self.pet.healthInfo.birthday = text
            }

        case "Weight" :

            cell.configur(cellStyle: .textfield, title: fields[indexPath.row] )
            cell.textField.keyboardType = .numberPad

            cell.callback = { text in
                guard let weight = Double(text) else { return }
                self.pet.healthInfo.weight = weight
            }

        case "WeightUnit" :

            cell.configur(cellStyle: .textfield, title: fields[indexPath.row] )

            cell.creatPicker(pickerData: ["kg","g"])

            cell.callback = { text in
                self.pet.healthInfo.weightUnit = text
            }



        case "Gender" :

            cell.configur(cellStyle: .textfield, title: fields[indexPath.row] )

            cell.creatPicker(pickerData: ["boy","girl"])

            cell.callback = { text in
                self.pet.healthInfo.gender = text
            }
            
            
        case "ChipId" :

            cell.configur(cellStyle: .textfield, title: fields[indexPath.row] )
            cell.callback = { text in
                self.pet.healthInfo.chipId = text
            }

        case "Allergy" :

            cell.configur(cellStyle: .more, title: fields[indexPath.row] )


        case "Note" :

            cell.configur(cellStyle: .more, title: fields[indexPath.row] )

        default:
            return cell
        }

        return cell
    }


}

