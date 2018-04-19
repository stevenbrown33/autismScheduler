//
//  AddChildViewController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

protocol AddChildDelegate: class {
    func viewActivities()
}

class AddChildViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var childPhotoButton: UIButton!
    @IBOutlet weak var childImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var assignActivitiesButton: UIButton!
    var child: Child?
    weak var delegate: AddChildDelegate?
    let childController = ChildController.shared
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Formatting
    func updateViews() {
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderWidth = 0.1
        assignActivitiesButton.layer.cornerRadius = 5
        assignActivitiesButton.layer.borderWidth = 0.1
        deleteButton.layer.cornerRadius = 5
        deleteButton.layer.borderWidth = 0.1
        nameTextField.layer.cornerRadius = 5
        nameTextField.delegate = self
        if let child = child {
            nameTextField.text = child.name
            childImageView.image = child.image
            saveButton.setTitle("Update", for: .normal)
        } else  {
            saveButton.setTitle("Save", for: .normal)
        }
    }
    
    // MARK: - Actions
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if let child = child {
            deleteConfirmation(child: child)
        } else {
            print("No child to delete")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
        print("View Dismissed")
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        save()
    }
    
    @IBAction func assignActivitiesButtonTapped(_ sender: UIButton) {
        save()
        childController.currentChild = self.child
        delegate?.viewActivities()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Saving
    func save() {
        guard let name = nameTextField.text, let image = childImageView.image else { return }
        //guard let data = UIImageJPEGRepresentation(image, 1) else { return }
        if name.isEmpty {
            createEmptyTextAlert()
            return
        } else {
            if let child = child {
                childController.update(child: child, name: name, image: image)
            } else {
                childController.addChild(withName: name, withImage: image)
            }
            dismiss(animated: true, completion: {
                print("Child created")
            })
        }
    }
    
    // MARK: - Alerts
    func deleteConfirmation(child: Child) {
        let deleteConfirmationAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this child?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            print("Action cancelled")
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.childController.deleteChild(child: child)
            self.dismiss(animated: true)
            print("Child deleted")
        }
        deleteConfirmationAlert.addAction(cancelAction)
        deleteConfirmationAlert.addAction(deleteAction)
        self.present(deleteConfirmationAlert, animated: true, completion: nil)
    }
    
    func createEmptyTextAlert() {
        let emptyTextAlert = UIAlertController(title: "Missing Name", message: "A child's name is required to move on.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default) { (action) in
            print("Alert dismissed")
        }
        emptyTextAlert.addAction(okayAction)
        self.present(emptyTextAlert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Image Picker
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickerImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            childImageView.contentMode = .scaleAspectFill
            childImageView.image = pickerImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
