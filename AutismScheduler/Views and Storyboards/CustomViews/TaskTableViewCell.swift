//
//  TaskTableViewCell.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/20/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var isSelectedButton: UIButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskImageView: UIImageView!
    var task: Task? {
        didSet {
            updateVIews()
        }
    }
    
    // MARK: - Actions
    @IBAction func isSelectedButtonTapped(_ sender: UIButton) {
    }
    
    func updateVIews() {
        guard let task = task else { return }
        taskNameLabel.text = task.name
        taskImageView.image = task.image
    }
}
