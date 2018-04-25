//
//  ActivityDetailViewController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/19/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var assignedTasksTableView: UITableView!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var addTaskImageView: UIImageView!
    @IBOutlet weak var addTaskLabel: UILabel!
    
    var activity: Activity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        assignedTasksTableView.delegate = self
//        assignedTasksTableView.dataSource = self
        updateViews()
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
        return TaskController.shared.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "assignedTaskCell", for: indexPath) as? AssignedTaskTableViewCell else { return UITableViewCell() }
        return cell
    }
}
