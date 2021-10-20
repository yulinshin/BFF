//
//  DiaryDeatilViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import UIKit

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!

    @IBOutlet weak var contentTextView: UITextView!

    @IBOutlet weak var postPetImageView: UIImageView!

    @IBOutlet weak var postPetNameLabel: UILabel!

    @IBOutlet weak var createdTimeLabel: UILabel!

    @IBOutlet weak var tagStackView: UIStackView!

    @IBOutlet weak var ccommentImage: UIImageView!

    @IBOutlet weak var commentLabel: UILabel!

    @IBOutlet weak var settingButton: UIButton!

    var viewModel = DetialViewModel()
    var comments = [String]()
    var petTags = [String]()
    var diaryId = ""
    private var oldContent = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        postPetImageView.layer.cornerRadius = postPetImageView.frame.height / 2

        viewModel.postPetImageUrl.bind {  [weak self] urlStr in
            self?.image.kf.setImage(with: URL(string: urlStr))
        }

        viewModel.contentText.bind {  [weak self] content in
            self?.contentTextView.text = content
        }

        viewModel.postPetImageUrl.bind {  [weak self] urlStr in
            self?.postPetImageView.kf.setImage(with: URL(string: urlStr))
        }

        viewModel.postPetsName.bind {  [weak self] name in
            self?.postPetNameLabel.text = name
        }

        viewModel.creatDate.bind {  [weak self] dateStr in
            self?.createdTimeLabel.text = dateStr
        }

        viewModel.numberOfComments.bind {  [weak self] count in
            self?.commentLabel.text = "\(count)"
        }

        viewModel.comments.bind {  [weak self] comments in
            self?.comments = comments
        }

        viewModel.petTags.bind {  [weak self] petTags in
            self?.petTags = petTags
        }

        viewModel.diaryId.bind {  [weak self] diaryId in
            self?.diaryId = diaryId
        }


        setPetsTag()

    }
    @IBAction func showMenu(_ sender: Any) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // Block PetsId -> Only show on other's Diary
        alertController.addAction(UIAlertAction(title: "Hide this diary", style: .default, handler: blockDiary))

        // Setting privacy Button
        viewModel.isPublic.bind(listener: { isPublic in
            if isPublic {

                alertController.addAction(UIAlertAction(title: "ToPrivate", style: .default, handler: self.editPrivacyToPrivate))

            } else {
                alertController.addAction(UIAlertAction(title: "ToPublic", style: .default, handler: self.editPrivacyToPublic))
            }
        })

            // Edit Diary Button
            alertController.addAction(UIAlertAction(title: "Edit Diary", style: .default, handler: editDiary))

            // Delete Diary Button
            alertController.addAction(UIAlertAction(title: "Delete Diary", style: .destructive, handler: deleteDiary))

            // Cancel Menu Button
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alertController, animated: true, completion: nil)

        }

// MARK: - Diary Menu Function

        // Block PetsId Action
        func blockDiary(_ action: UIAlertAction){
            print("tapped \(action.title!)")

        }

        // Setting privacy Action
        func editPrivacyToPublic(_ action: UIAlertAction){
            print("tapped \(action.title!)")
            viewModel.changePrivacy(isPublic: true)

        }

        func editPrivacyToPrivate(_ action: UIAlertAction){
        print("tapped \(action.title!)")
            viewModel.changePrivacy(isPublic: false)

        }

        func editDiary(_ action: UIAlertAction) {
            enterToEditMode()
            print("tapped \(action.title!)")
        }

    func enterToEditMode() {
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationItem.title = "Edit Diary"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveDiary))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelEditDiary))
        oldContent = contentTextView.text
        contentTextView.isEditable = true
        contentTextView.becomeFirstResponder()
    }

    func leaveEditMode() {
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationItem.title = ""
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        contentTextView.isEditable = false
        contentTextView.resignFirstResponder()
    }

    @objc func saveDiary() {

        viewModel.updateDiary(content: contentTextView.text)
        leaveEditMode()
        print("tapped save")
        }

    @objc func cancelEditDiary() {
        contentTextView.text = oldContent
        leaveEditMode()
        print("tapped cancel")
        }

        func deleteDiary(_ action: UIAlertAction) {

            FirebaseManager.shared.delateDiary(diaryId: diaryId) { result in
                switch result {
                case .success(let sucessMessage):
                    print(sucessMessage)

                case .failure(let error):
                    print("fetchData.failure\(error)")
                }
            }

            print("tapped \(action.title!)")

            self.navigationController?.popViewController(animated: true)

        }

        func setPetsTag() {
            tagStackView.subviews.forEach { subview in
                tagStackView.removeArrangedSubview(subview)
            }
            petTags.forEach { petName in
                let tag = UILabel()
                tag.text = petName
                tagStackView.addArrangedSubview(tag)
            }
        }

    }
