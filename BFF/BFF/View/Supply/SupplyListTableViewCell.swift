//
//  SupplyListTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/25.
//

import UIKit
import CoreData

class SupplyListTableViewCell: UITableViewCell {

    @IBOutlet weak var supplyIconImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var supplyNameLabel: UILabel!
    @IBOutlet weak var inventoryStatusLabel: UILabel!
    @IBOutlet weak var inventoryStatusView: UIStackView!
    @IBOutlet weak var maximumInventoryLabel: UILabel!
    @IBOutlet weak var remainingInventoryLabel: UILabel!
    @IBOutlet weak var cycleDosageLabel: UILabel!
    @IBOutlet weak var supplyUseByPetsStackView: UIStackView!
    @IBOutlet weak var remindIcon: UIImageView!
    @IBOutlet weak var remindLabel: UILabel!
    @IBOutlet weak var reFillStockButton: UIButton!
    @IBOutlet weak var cellCardBackGroundView: UIView!

    static let identifier = "SupplyListTableViewCell"

    var viewModel: SupplyViewModel?
    var unit: String?
    var userPetsData: [PetMO]?

    var didTapMoreButton: (() -> Void)?
    var didTapReFillButton: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

    }

    private func setupCellCardBackGroundView() {
        cellCardBackGroundView.layer.shadowColor = UIColor.gray.cgColor
        cellCardBackGroundView.layer.shadowOpacity = 0.2
        cellCardBackGroundView.layer.cornerRadius = 16
        cellCardBackGroundView.layer.shadowRadius = 4
        cellCardBackGroundView.backgroundColor = UIColor.white
        cellCardBackGroundView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    }

    // swiftlint:disable:next function_body_length
    func configure() {

        setupCellCardBackGroundView()
        reFillStockButton.layer.cornerRadius = 4

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

            let context = appDelegate.persistentContainer.viewContext
            do {
                let requests = try context.fetch(PetMO.fetchRequest())
                userPetsData = requests
            } catch {
                fatalError("ERROR:\(error)")
            }

        }

        viewModel?.supplyIconImage.bind(listener: { imageName in
            self.supplyIconImageView.image = UIImage(named: imageName)
            self.supplyIconImageView.layer.cornerRadius = 16
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

            self.progressView.progress = Float(percentage)
            UIView.animate(withDuration: 1, delay: 0.5, options: [], animations: { [unowned self] in
                progressView.layoutIfNeeded()
            })

        })

        viewModel?.maxInventory.bind(listener: { number in

            self.viewModel?.supplyUnit.bind(listener: { unit in

                self.maximumInventoryLabel.text = "\(number)\(unit)"

            })

        })

        viewModel?.remainingInventory.bind(listener: { number in

            self.viewModel?.supplyUnit.bind(listener: { unit in

                self.remainingInventoryLabel.text = "\(number)\(unit)"

            })

        })

        viewModel?.cycleDosage.bind(listener: { number in

            self.viewModel?.supplyUnit.bind(listener: { unit in

                self.cycleDosageLabel.text = "\(number)\(unit)"

            })

        })

        viewModel?.supplyUseByPets.bind(listener: { petIds in

            // CleanStock
            self.supplyUseByPetsStackView.subviews.forEach { view in
                view.removeFromSuperview()
            }

            petIds.forEach { petId in
                self.userPetsData?.forEach({ petData in
                    if petData.petId == petId {
                        let petImageView = UIImageView()
                        petImageView.translatesAutoresizingMaskIntoConstraints = false
                        petImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
                        petImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
                        petImageView.loadImage(petData.thumbNail?.url)
                        petImageView.contentMode = .scaleAspectFill
                        petImageView.layer.cornerRadius = 15
                        petImageView.clipsToBounds = true
                        self.supplyUseByPetsStackView.addArrangedSubview(petImageView)
                    } else {
                        return
                    }

                })
            }

        }
    )

        viewModel?.isNeedToRemind.bind(listener: { isNeedToRemind in

            self.viewModel?.remindPercentage.bind(listener: { percentage in

                if isNeedToRemind {

                    self.remindIcon.image = UIImage(systemName: "bell")
                    self.remindLabel.text = "低於\(Int(percentage))%時提醒"

                } else {

                    self.remindIcon.image = UIImage(systemName: "bell.slash")
                    self.remindLabel.text = "不提醒"

                }

            })

        })

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func tapMoreButton(_ sender: UIButton) {

        didTapMoreButton?()

    }
    @IBAction func tapReFillStock(_ sender: Any) {

        didTapReFillButton?()

    }

}
