//
//  TaskListViewController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/19/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

class TaskListViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, TaskTableViewCellDelegate, UISearchBarDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var taskImageView: UIImageView!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var saveTaskButton: UIButton!
    @IBOutlet weak var availableTasksLabel: UILabel!
    @IBOutlet weak var taskListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addTasksButton: UIButton!
    @IBOutlet weak var addTasksImageView: UIImageView!
    @IBOutlet weak var addTasksLabel: UILabel!
    var task: Task?
    let taskController = TaskController.shared
    var tasks: [Task] = []
    var child: Child?
    
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tasks = taskController.tasks
        taskListTableView.delegate = self
        taskListTableView.dataSource = self
        taskListTableView.reloadData()
        searchBar.delegate = self
        taskListTableView.reloadData()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
        taskListTableView.reloadData()
        guard let child = ChildController.shared.currentChild else { return }
        taskController.updateChildCheckedTasks(child: child, tasks: tasks) {
            DispatchQueue.main.async {
                self.taskListTableView.reloadData()
            }
        }
    }

    
    // MARK: - Formatting
    func updateViews() {
        selectImageButton.layer.cornerRadius = 5
        selectImageButton.layer.borderWidth = 0.1
        saveTaskButton.layer.cornerRadius = 5
        saveTaskButton.layer.borderWidth = 0.1
        taskNameTextField.layer.cornerRadius = 5
        taskNameTextField.delegate = self
        taskImageView.isHidden = true
        if tasks.count == 0 {
            taskListTableView.isHidden = true
            availableTasksLabel.isHidden = true
        } else {
            taskListTableView.isHidden = false
            availableTasksLabel.isHidden = false
        }
        if taskImageView.image != nil {
            selectImageButton.titleLabel?.text = "Image Already Selected"
        } else {
            selectImageButton.titleLabel?.text = "Select an Image"
        }
    }
    
    // MARK: - Actions
    @IBAction func saveTaskButtonTapped(_ sender: Any) {
        save()
        taskListTableView.reloadData()
    }
    
    func selectionButtonTapped(_ sender: TaskTableViewCell) {
        guard let indexPath = taskListTableView.indexPath(for: sender) else { return }
        let task = taskController.tasks[indexPath.row]
        guard let child = child else { return }
        taskController.toggleIsCheckedFor(task: task, child: child)
        taskListTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @IBAction func addTasksButtonTapped(_ sender: Any) {

    }
    
    // MARK: - Saving
    func save() {
        if (taskNameTextField.text)?.isEmpty == true || (taskImageView.image) == nil {
            createMissingInfoAlert()
            return
        } else {
            guard let name = taskNameTextField.text, let image = taskImageView.image else { return }
            taskController.addTask(named: name, withImage: image)
            taskNameTextField.text = ""
            taskImageView.image = nil
            selectImageButton.titleLabel?.text = "Select an Image"
            print("Task created")
        }
    }
    
    // MARK: - Alerts
    func deleteConfirmation(task: Task) {
        let deleteConfirmationAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            print("Action cancelled")
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.taskController.deleteTask(task: task)
            self.taskListTableView.reloadData()
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
            taskImageView.contentMode = .scaleAspectFit
            taskImageView.image = pickerImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableVIew
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
        let task = tasks[indexPath.row]
        cell.task = task
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            tasks.remove(at: indexPath.row)
            deleteConfirmation(task: task)
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
            self.tasks = taskController.tasks
            taskListTableView.reloadData()
        } else {
            guard let searchString = searchBar.text else { return }
            updateTaskSearch(searchString: searchString)
        }
    }
    
    func updateTaskSearch(searchString: String) {
        let filteredTasks = taskController.tasks.filter({ $0.matches(searchString: searchString) })
        tasks = filteredTasks
        taskListTableView.reloadData()
    }
}
