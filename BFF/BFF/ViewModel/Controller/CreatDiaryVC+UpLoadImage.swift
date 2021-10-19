//
//  CreatDiaryVC+UpLoadImage.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import UIKit

extension CreatDiaryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func handleSelectedDiaryImage(){
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.allowsEditing = true

        self.present(picker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("chancled picker")
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        var slectedImageFromPicker: UIImage?

        if let editedImage = info[.editedImage] as? UIImage{
            slectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage{
            print(originalImage.size)
            slectedImageFromPicker = originalImage
        }

        if let selectedImage = slectedImageFromPicker{
            imageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

}
