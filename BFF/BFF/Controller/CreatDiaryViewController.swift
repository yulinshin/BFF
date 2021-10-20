//
//  CreatDiaryViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import UIKit

class CreatDiaryViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedPetsCollectionView.delegate = self
        selectedPetsCollectionView.dataSource = self
        let petNib = UINib(nibName: "SelectedPetsCollectionViewCell", bundle: nil)
        selectedPetsCollectionView.register(petNib, forCellWithReuseIdentifier: SelectedPetsCollectionViewCell.identifier)
        selectedPetsCollectionView.allowsMultipleSelection = true
        fetchData()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectedDiaryImage))
        imageView.addGestureRecognizer(tapGR)
        imageView.isUserInteractionEnabled = true

        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationItem.title = "Creat Diary"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveDiary))

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelEditDiary))
        
    }

    @objc func saveDiary() {

        guard let petsId = petsData.first?.petId,
              let image = imageView.image else {
                  return
              }
        FirebaseManager.shared.uploadPhoto(image: image, filePath: .dairyPhotos) { result in

            switch result {

            case .success(let urlString):

                FirebaseManager.shared.creatDiary(content: self.diaryTextView.text, imageUrls: [urlString], isPublic: true, petTags: [petsId])

                // fozen VC with indcater

                self.navigationController?.dismiss(animated: true, completion: nil)

                // present to PostVC

            case .failure(let error):
                print("fetchData.failure\(error)")

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
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CreatDiaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        petsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // swiftlint:disable:next line_length
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedPetsCollectionViewCell.identifier, for: indexPath) as? SelectedPetsCollectionViewCell else { return UICollectionViewCell()}
        
        let imageStr = petsData[indexPath.row].petThumbnail
        let petId = petsData[indexPath.row].petId
        cell.congfigure(with: PhotoCellViewlModel(with: imageStr), petId: petId)
        
        return cell
        
    }
}

extension CreatDiaryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == selectedPetsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor.orange.cgColor
            cell.selectBackground.layer.borderWidth = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == selectedPetsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectedPetsCollectionViewCell else { return }
            cell.selectBackground.layer.borderColor = UIColor.orange.cgColor
            cell.selectBackground.layer.borderWidth = 0
        }
    }
    
}

extension CreatDiaryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == selectedPetsCollectionView {
            return CGSize(width: 70, height: 70)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
}
