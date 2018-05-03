//
//  ActivityDetailViewController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/19/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

class ActivityDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var assignedTasksTableView: UITableView!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var addTaskImageView: UIImageView!
    @IBOutlet weak var addTaskLabel: UILabel!
    @IBOutlet weak var changeTasksView: UIView!
    @IBOutlet weak var requiredTasksLabel: UILabel!
    
    var activity: Activity?
    var child: Child?
    var task: Task?
    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignedTasksTableView.delegate = self
        assignedTasksTableView.dataSource = self
        DispatchQueue.main.async {
            self.assignedTasksTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tasks = TaskController.shared.tasks
        guard let child = child else { return }
        setCheckedTasksFor(child: child)
        tasks = tasks.filter({$0.isChecked == true})
        DispatchQueue.main.async {
            self.assignedTasksTableView.reloadData()
        }
        formatting()
        updateViews()
    }
    
    func setCheckedTasksFor(child: Child) {
        for task in tasks {
            let childName = child.cloudKitRecord.recordID.recordName
            let taskName = task.cloudKitRecord.recordID.recordName
            guard let activityName = activity?.cloudKitRecord.recordID.recordName else { return }
            
            let childDict = UserDefaults.standard.value(forKey: childName) as? [String: Any] ?? [:]
            var childDictionary = childDict
            let checkedTasksForActivity = childDictionary[activityName] as? [String] ?? []
            
            if checkedTasksForActivity.contains(taskName) {
                task.isChecked = true
            } else {
                task.isChecked = false
            }
        }
    }
    
    func updateViews() {
        guard let activity = activity else { return }
        activityImageView.image = activity.image
        activityNameLabel.text = activity.name
    }
    
    func formatting() {
        view.backgroundColor = .defaultBackgroundColor
//        let backgroundLayer = UIHelper.shared.gradientLayer
//        backgroundLayer.frame = view.frame
//        view.layer.insertSublayer(backgroundLayer, at: 0)
        
        activityNameLabel.textColor = .defaultTextColor
        requiredTasksLabel.textColor = .defaultTextColor
        
        addTaskLabel.textColor = .defaultTextColor
        addTaskImageView.image = addTaskImageView.image?.withRenderingMode(.alwaysTemplate)
        addTaskImageView.tintColor = .defaultTintColor
        
        assignedTasksTableView.backgroundColor = .clear
        assignedTasksTableView.separatorStyle = .none
        
        changeTasksView.backgroundColor = .clear
        
        navigationController?.navigationBar.tintColor = .defaultTintColor
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    // MARK: - Actions
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskList" {
            guard let detailVC = segue.destination as? TaskListViewController else { return }
            detailVC.activity = activity
        }
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "assignedTaskCell", for: indexPath) as? AssignedTaskTableViewCell else { return UITableViewCell() }
        let task = tasks[indexPath.row]
        cell.backgroundColor = .clear
        cell.task = task
        return cell
    }
}
