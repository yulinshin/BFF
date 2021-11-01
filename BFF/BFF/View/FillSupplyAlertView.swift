

import Foundation
import UIKit

class FillSupplyAlertView: UIView {
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
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
    // fatalError("init(coder:) has not been implemented")
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

        self.titleLbl.text = supplyViewModel.supplyName.value

        self.messageLbl.text = "現有庫存數量為\(supplyViewModel.reminingInventory.value),要補充多少呢？"

        img.image = UIImage(named: supplyViewModel.supplyIconImage.value)
        img.backgroundColor = UIColor(named: supplyViewModel.iconColor.value)

        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(parentView)

    }


    @IBAction func onCliclExit(_ sender: Any) {
        parentView.removeFromSuperview()
    }

    
    @IBAction func onClickDone(_ sender: Any) {

        guard let supplyViewModel = supplyViewModel else { return }

        let stockstr = reFillStockTextField.text ?? "0"
        let stock = Int(stockstr) ?? 0
        supplyViewModel.reminingInventory.value += stock

        if supplyViewModel.maxInventory.value < supplyViewModel.reminingInventory.value {
            supplyViewModel.maxInventory.value = supplyViewModel.reminingInventory.value
        }
        if supplyViewModel.isNeedToRemind.value {
            guard let supply = supplyViewModel.suppply else { return }
            NotificationManger.shared.creatSupplyNotification(supply: supply )
        }
        // swiftlint:disable:next line_length
        let supply = Supply(color: supplyViewModel.iconColor.value, cycleTime: supplyViewModel.cycleTime.value, forPets: supplyViewModel.supplyUseByPets.value, fullStock: supplyViewModel.maxInventory.value, iconImage: supplyViewModel.supplyIconImage.value, isReminder: supplyViewModel.isNeedToRemind.value, perCycleTime: supplyViewModel.cycleDosage.value, reminderPercent: supplyViewModel.remindPercentage.value, stock: supplyViewModel.reminingInventory.value, supplyId: supplyViewModel.supplyId.value, supplyName: supplyViewModel.supplyName.value, unit: supplyViewModel.supplyUnit.value)

        FirebaseManager.shared.updateSupply(supplyId: supply.supplyId, data: supply)

        parentView.removeFromSuperview()
    }
    
    
    
    
    
    
    
}
