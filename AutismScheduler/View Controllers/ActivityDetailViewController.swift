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
        self.tasks = TaskController.shared.tasks
        assignedTasksTableView.delegate = self
        assignedTasksTableView.dataSource = self
        updateViews()
        guard let child = child else { return }
        setCheckedTasksFor(child: child)
    }
    
    func updateViews() {
        guard let activity = activity else { return }
        activityImageView.image = activity.image
        activityNameLabel.text = activity.name
    }
    
    // MARK: - Actions
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let child = ChildController.shared.currentChild else { return 0 }
        return child.checkedTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "assignedTaskCell", for: indexPath) as? AssignedTaskTableViewCell else { return UITableViewCell() }
        let child = ChildController.shared.currentChild
        let task = child?.checkedTasks[indexPath.row]
        return cell
    }
}
