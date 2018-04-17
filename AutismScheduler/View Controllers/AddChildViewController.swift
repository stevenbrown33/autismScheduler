//
//  AddChildViewController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class AddChildViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var childImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    var child: Child?
    let imagePicker = UIImagePickerController()
    let childController = ChildController.shared
    
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if let child = child {
            deleteConfirmation(child: child)
        } else {
            print("No child to delete")
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        save()
        dismiss(animated: true) {
            print("Child created")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        setupChildImageView()
    }
    
    func updateViews() {
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderWidth = 0.1
        deleteButton.layer.cornerRadius = 5
        deleteButton.layer.borderWidth = 0.1
        nameTextField.layer.cornerRadius = 5
        if let child = child {
            nameTextField.text = child.name
            saveButton.setTitle("Update", for: .normal)
        } else  {
            saveButton.setTitle("Save", for: .normal)
        }
    }
    
    func setupChildImageView() {
        childImageView.clipsToBounds = true
        childImageView.layer.cornerRadius = 5
        childImageView.contentMode = .scaleAspectFill
    }
    
    func save() {
        guard let name = nameTextField.text else { return }
                if name.isEmpty {
                    return
                } else {
                    if let child = child {
                        childController.updateChild(child, withName: name)
                        //childController.updateChildImage(for: child, toImage: image)
                    } else {
                        childController.addChild(withName: name)
                        //ChildController.shared.updateChildImage(for: child, toImage: image)
                    }
                }
    }
    
    func deleteConfirmation(child: Child) {
        let deleteConfirmationAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this child?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            print("Action cancelled")
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.childController.removeChild(child)
            self.dismiss(animated: true, completion: nil)
            print("Child deleted")
        }
        deleteConfirmationAlert.addAction(cancelAction)
        deleteConfirmationAlert.addAction(deleteAction)
        self.present(deleteConfirmationAlert, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension AddChildViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let childImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        childImageView.image = childImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension UIImagePickerController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
