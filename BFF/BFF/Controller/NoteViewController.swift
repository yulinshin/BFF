//
//  NoteViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/20.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var noteTextView: UITextView!

    
    @IBOutlet weak var titleLabel: UILabel!

    var callBack: ((_ note: String) -> Void)?

    var note = ""
    var petsName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        noteTextView.text = note
        if petsName == ""{
            titleLabel.text = "毛小孩的的備註事項"
        }else{
            titleLabel.text = "\(petsName)的備註事項"
        }

    }

    func textViewDidEndEditing(_ textView: UITextView) {
        callBack?(textView.text)
    }

}
