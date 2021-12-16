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

    static var identifier = "DiaryDetailViewController"
    private var viewModel: DetailViewModel
    private var oldContent = "" // Keep original content information for edit mode.

    init?(coder: NSCoder, diary: Diary) {
        self.viewModel = DetailViewModel(from: diary)
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCommentInteraction()

        setupUI()

        checkDiaryOwner()

        bindingData()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.mainColor
    }

    private func setupUI() {
        contentTextView.sizeToFit()
        postPetImageView.layer.cornerRadius = postPetImageView.frame.height / 2
    }

    private func setupCommentInteraction() {
        commentImage.isUserInteractionEnabled = true
        commentImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapComment)))
    }

    @objc func didTapComment() {

        if let detailController = self.storyboard?.instantiateViewController(identifier: "CommentTableViewController", creator: { coder in
            CommentTableViewController(coder: coder, diary: self.viewModel.diary)
        }) {
            self.navigationController?.show(detailController, sender: nil)
        }

    }

    private func checkDiaryOwner() {
        if viewModel.diary.userId != FirebaseManager.shared.userId {
            settingButton.isHidden = true
        } else {
            settingButton.isHidden = false
        }
    }

    private func bindingData() {
        viewModel.postImageUrl.bind {  [weak self] urlStr in
            self?.image.kf.setImage(with: URL(string: urlStr))
        }

        viewModel.contentText.bind {  [weak self] content in
            print(content)
            self?.contentTextView.text = content
        }

        viewModel.postPetImageUrl.bind { [weak self] urlStr in
            self?.postPetImageView.kf.setImage(with: URL(string: urlStr))
        }

        viewModel.postPetsName.bind { [weak self] name in
            self?.postPetNameLabel.text = name
        }

        viewModel.createDate.bind { [weak self] dateStr in
            self?.createdTimeLabel.text = dateStr
        }

        viewModel.numberOfComments.bind { [weak self] count in
            self?.commentLabel.text = "\(count)"
        }

        viewModel.comments.bind { [weak self] comments in
            self?.commentLabel.text = "\(comments.count)"
        }

        viewModel.isPublic.bind { [weak self] isPublic in
            if isPublic {
                self?.diaryStateLabel.text = "Public"
            } else {
                self?.diaryStateLabel.text = "Private"
            }
        }
        likeCountLabel.text = "\(viewModel.diary.whoLiked.count)"

    }

    @IBAction func showMenu(_ sender: Any) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if viewModel.isPublic.value {
            alertController.addAction(UIAlertAction(title: "ToPrivate", style: .default, handler: self.editPrivacyToPrivate))

        } else {
            alertController.addAction(UIAlertAction(title: "ToPublic", style: .default, handler: self.editPrivacyToPublic))
        }

        alertController.addAction(UIAlertAction(title: "Edit Diary", style: .default, handler: editDiary))

        alertController.addAction(UIAlertAction(title: "Delete Diary", style: .destructive, handler: deleteDiary))

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        self.present(alertController, animated: true, completion: nil)

    }

    // MARK: - Diary Menu Function

    // Setting privacy Action
    private func editPrivacyToPublic(_ action: UIAlertAction) {
        print("tapped \(action.title!)")
        viewModel.changePrivacy(isPublic: true)
        self.diaryStateLabel.text = "Public"

    }

    private func editPrivacyToPrivate(_ action: UIAlertAction) {
        print("tapped \(action.title!)")
        viewModel.changePrivacy(isPublic: false)
        self.diaryStateLabel.text = "Private"

    }

    private func editDiary(_ action: UIAlertAction) {
        enterToEditMode()
        print("tapped \(action.title!)")
    }

    private func enterToEditMode() {
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationItem.title = "Edit Diary"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(saveDiary))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancelEditDiary))
        oldContent = contentTextView.text
        contentTextView.isEditable = true
        contentTextView.becomeFirstResponder()
    }

    private func leaveEditMode() {
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
    }

    @objc func cancelEditDiary() {
        contentTextView.text = oldContent
        leaveEditMode()
    }

    func deleteDiary(_ action: UIAlertAction) {
        viewModel.deleteDiary()
        self.navigationController?.popViewController(animated: true)
    }
}
