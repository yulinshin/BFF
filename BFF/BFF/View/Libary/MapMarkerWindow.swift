//
//  MapMarkerWindow.swift
//  BFF
//
//  Created by yulin on 2021/11/2.
//

import UIKit

protocol MapMarkerDelegate: class {
    func didTapInfoButton(data: Location)
}

class MapMarkerWindow: UIView {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!

    weak var delegate: MapMarkerDelegate?
    var spotData: Location?

    @IBAction func didLinkButton(_ sender: UIButton) {
        delegate?.didTapInfoButton(data: spotData!)
    }

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView ?? UIView()
    }
}
