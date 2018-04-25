//
//  ActivityListViewController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/19/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class ActivityListViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ActivityTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityNameTextField: UITextField!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var saveActivityButton: UIButton!
    @IBOutlet weak var availableActivitiesLabel: UILabel!
    @IBOutlet weak var activityListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var activity: Activity?
    let activityController = ActivityController.shared
    var activities: [Activity] = []

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        activityListTableView.delegate = self
        activityListTableView.dataSource = self
        searchBar.delegate = self
        activityListTableView.reloadData()
        updateViews()
        self.activities = activityController.activities
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
        activityListTableView.reloadData()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Formatting
    func updateViews() {
        selectImageButton.layer.cornerRadius = 5
        selectImageButton.layer.borderWidth = 0.1
        saveActivityButton.layer.cornerRadius = 5
        saveActivityButton.layer.borderWidth = 0.1
        activityNameTextField.layer.cornerRadius = 5
        activityNameTextField.delegate = self
        activityImageView.isHidden = true
        if activities.count == 0 {
            activityListTableView.isHidden = true
            availableActivitiesLabel.isHidden = true
        } else {
            activityListTableView.isHidden = false
            availableActivitiesLabel.isHidden = false
        }
        if activityImageView.image != nil {
            selectImageButton.titleLabel?.text = "Image Already Selected"
        } else {
            selectImageButton.titleLabel?.text = "Select an Image"
        }
    }
    
    // MARK: - Actions
    @IBAction func saveActivityButtonTapped(_ sender: UIButton) {
        save()
        activityListTableView.reloadData()
    }
    
    func selectionButtonTapped(_ sender: ActivityTableViewCell) {
        guard let indexPath = activityListTableView.indexPath(for: sender) else { return }
        let activity = activityController.activities[indexPath.row]
        activityController.toggleIsCheckedFor(activity: activity)
        activityListTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Saving
    func save() {
        if (activityNameTextField.text)?.isEmpty == true || (activityImageView.image) == nil {
            createMissingInfoAlert()
            return
        } else {
            guard let name = activityNameTextField.text, let image = activityImageView.image else { return }
            activityController.addActivity(named: name, withImage: image)
            activityNameTextField.text = ""
            activityImageView.image = nil
            selectImageButton.titleLabel?.text = "Select an Image"
            print("Activity created")
        }
    }
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toActivityDetail" {
            if let indexPath = activityListTableView.indexPathForSelectedRow {
                let activity = activityController.activities[indexPath.row]
                guard let detailVC = segue.destination as? ActivityDetailViewController else { return }
                detailVC.activity = activity
            }
        }
     }
    
    // MARK: - Alerts
    func deleteConfirmation(activity: Activity) {
        let deleteConfirmationAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this activity?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            print("Action cancelled")
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.activityController.deleteActivity(activity: activity)
            self.activityListTableView.reloadData()
            self.dismiss(animated: true)
            print("Activity deleted")
        }
        deleteConfirmationAlert.addAction(cancelAction)
        deleteConfirmationAlert.addAction(deleteAction)
        self.present(deleteConfirmationAlert, animated: true, completion: nil)
    }
    
    func createMissingInfoAlert() {
        let emptyTextAlert = UIAlertController(title: "Missing Information", message: "An activity name and image is required.", preferredStyle: .alert)
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
    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickerImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            activityImageView.contentMode = .scaleAspectFit
            activityImageView.image = pickerImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - TableVIew
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as? ActivityTableViewCell else { return UITableViewCell() }
        let activity = activities[indexPath.row]
        cell.activity = activity
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let activity = activities[indexPath.row]
            activities.remove(at: indexPath.row)
            deleteConfirmation(activity: activity)
        }
    }
    
    // MARK: - SearchBar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.activities = activityController.activities
            activityListTableView.reloadData()
        } else {
            guard let searchString = searchBar.text else { return }
            updateActivitySearch(searchString: searchString)
        }
    }
    
    func updateActivitySearch(searchString: String) {
        let filteredActivities = activityController.activities.filter({ $0.matches(searchString: searchString) })
        activities = filteredActivities
        activityListTableView.reloadData()
    }
}
