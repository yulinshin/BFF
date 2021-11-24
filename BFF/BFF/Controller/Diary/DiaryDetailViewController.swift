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

    @IBOutlet weak var commentImage: UIImageView!

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!

    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var diaryStateLabel: UILabel!

    var viewModel = DetailViewModel()
    var comments = [String]()
    var petTags = [String]()
    var diaryId = ""
    
    private var oldContent = ""

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor(named: "main")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentTextView.sizeToFit()

        postPetImageView.layer.cornerRadius = postPetImageView.frame.height / 2

        if viewModel.diary?.userId != FirebaseManager.shared.userId {
            settingButton.isHidden = true
        } else {
            settingButton.isHidden = false
        }

        viewModel.postImageUrl.bind {  [weak self] urlStr in
            self?.image.kf.setImage(with: URL(string: urlStr))
        }

        viewModel.contentText.bind {  [weak self] content in
            print(content)
            self?.contentTextView.text = content
        }

        viewModel.postPetImageUrl.bind {  [weak self] urlStr in
            self?.postPetImageView.kf.setImage(with: URL(string: urlStr))
        }

        viewModel.postPetsName.bind {  [weak self] name in
            self?.postPetNameLabel.text = name
        }

        viewModel.createDate.bind {  [weak self] dateStr in
            self?.createdTimeLabel.text = dateStr
        }

        viewModel.numberOfComments.bind {  [weak self] count in
            self?.commentLabel.text = "\(count)"
        }

        viewModel.comments.bind {  [weak self] comments in
            self?.comments = comments
            self?.commentLabel.text = "\(comments.count)"
        }

        viewModel.petTags.bind {  [weak self] petTags in
            self?.petTags = petTags
        }

        viewModel.diaryId.bind {  [weak self] diaryId in
            self?.diaryId = diaryId
        }

        viewModel.isPublic.bind { isPublic in
            if isPublic {
                self.diaryStateLabel.text = "Public"
            } else {
                self.diaryStateLabel.text = "Private"
            }
        }
        if let count = viewModel.diary?.whoLiked.count {
            likeCountLabel.text = "\(count)"

        }

        commentImage.isUserInteractionEnabled = true
        commentImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapComment)))

    }

    @objc func didTapComment() {

        let storyboard = UIStoryboard(name: "Social", bundle: nil)

        guard let controller = storyboard.instantiateViewController(withIdentifier: "CommentTableViewController") as? CommentTableViewController else { return }
        controller.diary = viewModel.diary!
        self.navigationController?.pushViewController(controller, animated: true)

    }

    @IBAction func showMenu(_ sender: Any) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

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
            alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

            self.present(alertController, animated: true, completion: nil)

        }

// MARK: - Diary Menu Function

        // Setting privacy Action
        func editPrivacyToPublic(_ action: UIAlertAction) {
            print("tapped \(action.title!)")
            viewModel.changePrivacy(isPublic: true)
            self.diaryStateLabel.text = "Public"

        }

        func editPrivacyToPrivate(_ action: UIAlertAction) {
        print("tapped \(action.title!)")
            viewModel.changePrivacy(isPublic: false)
            self.diaryStateLabel.text = "Private"

        }

        func editDiary(_ action: UIAlertAction) {
            enterToEditMode()
            print("tapped \(action.title!)")
        }

    func enterToEditMode() {
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationItem.title = "Edit Diary"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(saveDiary))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancelEditDiary))
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

            print("tapped \(action.title!)")
            viewModel.deleteDiary()
            self.navigationController?.popViewController(animated: true)

        }
    }
