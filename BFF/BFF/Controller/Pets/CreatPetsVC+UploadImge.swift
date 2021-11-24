//
//  CreatDiaryVC+UpLoadImage.swift
//  BFF
//
//  Created by yulin on 2021/10/20.
//

import UIKit

extension CreatePetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func handleSelectedPetImage() {
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.allowsEditing = true

        self.present(picker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        var selectedImageFromPicker: UIImage?

        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            print(originalImage.size)
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            petImage.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

}
