//
//  SupplyListTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/25.
//

import UIKit

class SupplyListTableViewCell: UITableViewCell {

    @IBOutlet weak var supplyIconImageView: UIImageView!

    @IBOutlet weak var supplyNameLabel: UILabel!
    @IBOutlet weak var inventoryStatusLabel: UILabel!
    @IBOutlet weak var inventoryStatusView: UIStackView!
    @IBOutlet weak var maximumInventoryLabel: UILabel!
    @IBOutlet weak var remainingInventoryLabel: UILabel!
    @IBOutlet weak var cycleDosageLabel: UILabel!
    @IBOutlet weak var supplyUseByPetsStackVIew: UIStackView!
    @IBOutlet weak var remindIcon: UIImageView!
    @IBOutlet weak var remindLabel: UILabel!
    @IBOutlet weak var reFillStockButton: UIButton!
    @IBOutlet weak var cellCardBackGroundView: UIView!

    static let identifier = "SupplyListTableViewCell"

    var viewModel: SupplyViewModel?
    var unit: String?

    var didTapMoreButtom: (()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    func configur(){

        // Layout

        cellCardBackGroundView.layer.shadowColor = UIColor.gray.cgColor
        cellCardBackGroundView.layer.shadowOpacity = 0.2
        cellCardBackGroundView.layer.cornerRadius = 16
        cellCardBackGroundView.layer.shadowRadius = 4
        cellCardBackGroundView.backgroundColor = UIColor.white
        cellCardBackGroundView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)

        reFillStockButton.layer.cornerRadius = 4


        // Data Binding
        viewModel?.supplyIconImage.bind(listener: { imageName in
            self.supplyIconImageView.image = UIImage(named: imageName)
        })

        viewModel?.iconColor.bind(listener: { iconColor in
            self.supplyIconImageView.backgroundColor = UIColor(named: iconColor)
        })


        viewModel?.supplyName.bind(listener: { supplyName in
            self.supplyNameLabel.text = supplyName
        })

        viewModel?.inventoryStatusText.bind(listener: { text in
            self.inventoryStatusLabel.text = text
        })

        viewModel?.inventoryStatusPercentage.bind(listener: { percentage in

            // Draw PercentageView

        })

        viewModel?.maxInventory.bind(listener: { number in

            self.viewModel?.supplyUnit.bind(listener: { unit in

                self.maximumInventoryLabel.text = "\(number)\(unit)"

            })

        })

        viewModel?.reminingInventory.bind(listener: { number in

            self.viewModel?.supplyUnit.bind(listener: { unit in

                self.remainingInventoryLabel.text = "\(number)\(unit)"

            })

        })

        viewModel?.cycleDosage.bind(listener: { number in

            self.viewModel?.supplyUnit.bind(listener: { unit in

                self.cycleDosageLabel.text = "\(number)\(unit)"

            })

        })

        viewModel?.supplyUseByPets.bind(listener: { pets in

            // CleanStock
            self.supplyUseByPetsStackVIew.subviews.forEach { view in
                view.removeFromSuperview()
            }

            pets.forEach { pet in

                // GetPetsThumbnail
                FirebaseManager.shared.getPhoto(fileName: pet, filePath: .petPhotos) { result in

                    switch result {

                    case .success(let pic):

                        let petImageView = UIImageView()
                        petImageView.loadImage(pic.url)

                        // SetPetsThumbnail
                        self.supplyUseByPetsStackVIew.addArrangedSubview(petImageView)

                    case .failure(let error):

                        print(error)

                    }
                }

            }
            })

        viewModel?.isNeedToRemind.bind(listener: { isNeedToRemind in


            self.viewModel?.remindPercentage.bind(listener: { percentage in

                if isNeedToRemind {

                    self.remindIcon.image = UIImage(systemName: "bell.slash")
                    self.remindLabel.text = "低於\(percentage)%時提醒"

                } else {

                    self.remindIcon.image = UIImage(systemName: "bell")
                    self.remindLabel.text = "不提醒"

                }

            })

        })




    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func tapMoreButton(_ sender: UIButton) {

        didTapMoreButtom?()

    }
    @IBAction func tapReFillStock(_ sender: Any) {
    }

}
