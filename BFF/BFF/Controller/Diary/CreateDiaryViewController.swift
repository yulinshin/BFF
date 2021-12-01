//
//  CreatDiaryViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import UIKit

class CreateDiaryViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var diaryTextView: UITextView!
    
    @IBOutlet weak var selectedPetsCollectionView: UICollectionView!
    
    @IBOutlet weak var tagPets: UIButton!

    @IBOutlet weak var tagPetStackView: UIStackView!

    var petsData = [Pet]() {
        didSet {
            selectedPetsCollectionView.reloadData()
        }
    }
    
    var diaryImage: UIImage?

    var selectedPetId: String?

    var petTags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        diaryTextView.text = "寫下毛小孩的日記...."
        diaryTextView.textColor = UIColor.lightGray
        diaryTextView.delegate = self
        selectedPetsCollectionView.delegate = self
        selectedPetsCollectionView.dataSource = self
        let petNib = UINib(nibName: "SelectedPetsCollectionViewCell", bundle: nil)
        selectedPetsCollectionView.register(petNib, forCellWithReuseIdentifier: SelectedPetsCollectionViewCell.identifier)
        selectedPetsCollectionView.allowsMultipleSelection = false
        fetchData()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectedDiaryImage))
        imageView.addGestureRecognizer(tapGR)
        imageView.isUserInteractionEnabled = true

        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationItem.title = "新增毛小孩的日記"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(saveDiary))

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancelEditDiary))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.mainColor
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.mainColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if petsData.count == 0 {
            self.showNoPetAlert()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NetStatusManger.share.startMonitoring()

    }

    override func viewDidDisappear(_ animated: Bool) {
        NetStatusManger.share.stopMonitoring()
    }

    @objc func saveDiary() {

        guard let petId = selectedPetId,
              let image = imageView.image else {
                  showDiaryNotComplictedAlert()
                  return
              }

        ProgressHUD.show()

        FirebaseManager.shared.uploadPhoto(image: image, filePath: .dairyPhotos) { result in

            switch result {

            case .success(let pic):

                let diary = Diary(content: self.diaryTextView.text, diaryId: "", images: [pic], isPublic: true, petTags: self.petTags, userId: FirebaseManager.userId, petId: petId)

                FirebaseManager.shared.createDiary(diary: diary) { result in

                    switch result {

                    case.success(let message):
                        print(message)
                        ProgressHUD.showSuccess(text: "新增日記成功")

                    case.failure(let error):

                        switch error {

                        case .noNetWorkContent:

                            ProgressHUD.showFailure(text: "無網路連線")

                        case .gotFirebaseError( let error ):

                            ProgressHUD.showFailure(text: "上傳失敗，請重新上傳")
                            print(error)
                        }
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }

            case .failure(let error):

                switch error {

                case .noNetWorkContent:

                    ProgressHUD.showFailure(text: "無網路連線")

                case .gotFirebaseError(let error):

                    ProgressHUD.showFailure(text: "上傳失敗，請重新上傳")
                    print(error)
                }

            }

        }
    }

    @IBAction func tagPets(_ sender: Any) {

    }

    @objc func cancelEditDiary() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func fetchData() {
        
        FirebaseManager.shared.fetchPets { result in
            
            switch result {
                
            case .success(let pets):
                
                var petsData = [Pet]()
                pets.forEach { pet in
                    petsData.append(pet)
                }
                self.petsData = petsData
                
            case .failure(let error):
                print("fetchData.failure\(error)")
                
            }
            
        }
        
    }

    func showNoPetAlert() {

        let alertController = UIAlertController(title: "您尚無毛小孩唷", message: "請至少新增一隻毛小孩才能進行填寫日記唷", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "前往新增", style: .default) { _ in

            let storyboard = UIStoryboard(name: "Pet", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "CreatePetViewController") as? CreatePetViewController else { return }
            controller.presentMode = .create
            self.navigationController?.present(controller, animated: true, completion: nil)

        }

        alertController.addAction(deleteAction)

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))

        self.present(alertController, animated: true, completion: nil)

    }

    func showDiaryNotComplictedAlert() {

        let alertController = UIAlertController(title: "日記不完整", message: "請確認日記資訊是否完整（至少上傳一張照片與選擇一隻毛小孩唷！）", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "了解！", style: .cancel))

        self.present(alertController, animated: true, completion: nil)

    }
}

extension CreateDiaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        petsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // swiftlint:disable:next line_length
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedPetsCollectionViewCell.identifier, for: indexPath) as? SelectedPetsCollectionViewCell else { return UICollectionViewCell()}
        
        let imageStr = petsData[indexPath.row].petThumbnail?.url
        let petId = petsData[indexPath.row].petId
        cell.configure(with: PhotoCellViewModel(with: imageStr ?? ""), petId: petId)
        
        return cell
        
    }
}

extension CreateDiaryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == selectedPetsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            selectedPetId = petsData[indexPath.row].petId
            cell.selectBackground.layer.borderColor = UIColor.mainColor.cgColor
            cell.selectBackground.layer.borderWidth = 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == selectedPetsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor.mainColor.cgColor
            cell.selectBackground.layer.borderWidth = 0
        }
    }
    
}

extension CreateDiaryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == selectedPetsCollectionView {
            return CGSize(width: 70, height: 70)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
}

extension CreateDiaryViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "寫下毛小孩的日記...."
            textView.textColor = UIColor.lightGray
        }
    }

}
