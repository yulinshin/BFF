//
//  FillSupplyAlertView.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import Foundation
import UIKit
import Firebase

class FillSupplyAlertView: UIView {
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var reFillStockTextField: UITextField!

    var supplyViewModel: SupplyViewModel?
    static let shared = FillSupplyAlertView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("FillSupplyAlertView", owner: self, options: nil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    print("init(coder:)")
    }
    override func awakeFromNib() {
    super.awakeFromNib()
    print("awakeFromNib()")
    }
    
    private func commonInit() {
        img.layer.cornerRadius = 30
        img.layer.borderColor = UIColor.white.cgColor
        img.layer.borderWidth = 2
        
        alertView.layer.cornerRadius = 10
        
        parentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        parentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    enum AlertType {
        case success
        case failure
    }
    
    func showAlert(supplyViewModel: SupplyViewModel) {

        self.supplyViewModel = supplyViewModel

        self.titleLabel.text = supplyViewModel.supplyName.value

        self.messageLabel.text = "現有庫存數量為\(supplyViewModel.remainingInventory.value),要補充多少呢？"

        img.image = UIImage(named: supplyViewModel.supplyIconImage.value)
        img.backgroundColor = UIColor(named: supplyViewModel.iconColor.value)

        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(parentView)

    }

    @IBAction func onCliclExit(_ sender: Any) {
        parentView.removeFromSuperview()
    }

    @IBAction func onClickDone(_ sender: Any) {

        guard let supplyViewModel = supplyViewModel else { return }

        let stockStr = reFillStockTextField.text ?? "0"
        let stock = Int(stockStr) ?? 0
        supplyViewModel.remainingInventory.value += stock

        if supplyViewModel.maxInventory.value < supplyViewModel.remainingInventory.value {
            supplyViewModel.maxInventory.value = supplyViewModel.remainingInventory.value
        }
        if supplyViewModel.isNeedToRemind.value {
            guard let supply = supplyViewModel.supply else { return }
            NotificationManger.shared.createSupplyNotification(supply: supply )
        }
        
        supplyViewModel.updateToDataBase()

        parentView.removeFromSuperview()
    }
}
