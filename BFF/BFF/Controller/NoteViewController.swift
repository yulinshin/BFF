//
//  NoteViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/20.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var noteTextView: UITextView!

    var callBack: ((_ note: String) -> Void)?

    var note = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        noteTextView.text = note
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        callBack?(textView.text)
    }

}
