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
    
    var activity: Activity?
    var child: Child?
    var tasks: [Task] = []
    
    func setCheckedTasksFor(child: Child) {
        for task in tasks {
            let record = task.cloudKitRecord
            let taskReference = CKReference(record: record, action: .none)
            if child.checkedTasks.contains(taskReference) {
                task.isChecked = true
            } else {
                task.isChecked = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tasks = activity?.tasks ?? []
        assignedTasksTableView.delegate = self
        assignedTasksTableView.dataSource = self
        updateViews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assignedTasksTableView.reloadData()
        
        guard let child = child else { return }
        setCheckedTasksFor(child: child)
        
        tasks = tasks.filter({$0.isChecked == true})
    }
    
    func updateViews() {
        guard let activity = activity else { return }
        activityImageView.image = activity.image
        activityNameLabel.text = activity.name
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
//        guard let child = ChildController.shared.currentChild else { return 0 }
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "assignedTaskCell", for: indexPath) as? AssignedTaskTableViewCell else { return UITableViewCell() }
        
        let task = tasks[indexPath.row]
        cell.task = task
        return cell
    }
}
