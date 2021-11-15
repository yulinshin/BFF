//
//  CommentTableViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/6.
//

import UIKit

class CommentTableViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var messageTextField: UITextField!
    var viewModels = [CommentViewModel]()
    var diary: Diary?
    var myPets = CoreDataManager.sharedInstance.fetchMyPets()
    var selectedPet: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self

        let petNib = UINib(nibName: "SelectedPetsCollectionViewCell", bundle: nil)
        collectionView.register(petNib, forCellWithReuseIdentifier: SelectedPetsCollectionViewCell.identifier)
        self.navigationController?.navigationBar.tintColor = UIColor(named: "main")
        getComments()

    }

    override func viewWillAppear(_ animated: Bool) {
        selectedPet = myPets?.first?.petId

    }

    override func viewDidDisappear(_ animated: Bool) {
    }


    @IBAction func sendMessage(_ sender: Any) {
        guard let message = messageTextField.text,
        let diary = diary,
        let selectedPet = selectedPet else {
            return
        }
        FirebaseManager.shared.creatComments(content: message, petId: selectedPet, diaryId: diary.diaryId)
        getComments()
        messageTextField.text = ""
    }

    func getComments(){

        viewModels = [CommentViewModel]()

        guard let diary = diary else { return }

        let firstChat = Comment(commentId: "", content: diary.content, createdTime: diary.createdTime, diaryId: diary.diaryId, petId: diary.petId)

        let chatViewModel = CommentViewModel(from: firstChat){
            self.tableView.reloadData()
        }
        self.viewModels.append(chatViewModel)

        FirebaseManager.shared.fetchComments(diaryId: diary.diaryId) { result in


            switch result {

            case .success(var comments):

                comments.sort { first, second in
                    first.createdTime.dateValue() < second.createdTime.dateValue()
                }

                comments.forEach { comment in
                    let chatViewModel = CommentViewModel(from: comment){
                        self.tableView.reloadData()
                    }
                    self.viewModels.append(chatViewModel)
                }

                self.tableView.reloadData()

            case .failure(let error):

                print(error)

            }

        }

    }

}



extension CommentTableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableCell", for: indexPath) as? CommentTableCell else {
            return UITableViewCell() }
        cell.setup(viewModel: viewModels[indexPath.row])
        cell.selectionStyle =  .none
        return cell
    }
}


extension CommentTableViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
            animateViewMoving(up: true, moveValue: 300)
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            animateViewMoving(up: false, moveValue: 300)
        }

        func animateViewMoving (up:Bool, moveValue :CGFloat){
            let movementDuration:TimeInterval = 0.3
            let movement:CGFloat = ( up ? -moveValue : moveValue)
            UIView.beginAnimations( "animateView", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(movementDuration )
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
            UIView.commitAnimations()
        }

}

extension CommentTableViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return myPets?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // swiftlint:disable:next line_length
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedPetsCollectionViewCell.identifier, for: indexPath) as? SelectedPetsCollectionViewCell,
        let myPets = myPets else { return UICollectionViewCell()}

        let imageStr = myPets[indexPath.row].thumbNail?.url
        let petId = myPets[indexPath.row].petId
        cell.congfigure(with: PhotoCellViewlModel(with: imageStr ?? ""), petId: petId ?? "")
        if selectedPet == petId {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            cell.isSelected = true
            cell.selectBackground.layer.borderColor = UIColor(named: "main")?.cgColor
            cell.selectBackground.layer.borderWidth = 2
        }

        return cell
    }



}



extension CommentTableViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
        cell.selectBackground.layer.borderColor = UIColor(named: "main")?.cgColor
            cell.selectBackground.layer.borderWidth = 3
            guard let myPets = myPets else { return }
            selectedPet = myPets[indexPath.row].petId

    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor.white.cgColor
            cell.selectBackground.layer.borderWidth = 0

    }

}


extension CommentTableViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            return CGSize(width: 40, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

    

class CommentTableCell: UITableViewCell{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var photImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    func setup(viewModel: CommentViewModel) {

        viewModel.name.bind { name in
            self.nameLabel.text = name
        }

        viewModel.content.bind { content in
            self.commentLabel.text = content
        }

        viewModel.pic.bind { url in
            self.photImageView.loadImage(url)
        }

        viewModel.date.bind { date in
            self.dateLabel.text = date
        }

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        photImageView.layer.cornerRadius = photImageView.bounds.height/2

    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

