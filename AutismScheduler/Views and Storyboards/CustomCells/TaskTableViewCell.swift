//
//  TaskTableViewCell.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/20/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

protocol TaskTableViewCellDelegate {
    func selectionButtonTapped(_ sender: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var isSelectedButton: UIButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskImageView: UIImageView!
    var delegate: TaskTableViewCellDelegate?
    var isChecked = false {
        didSet {
            updateSelectionButtonAppearance()
        }
    }
    var task: Task? {
        didSet {
            updateVIews()
        }
    }
    
    // MARK: - Actions
    @IBAction func isSelectedButtonTapped(_ sender: UIButton) {
        delegate?.selectionButtonTapped(self)
    }
    
    func updateVIews() {
        guard let task = task else { return }
        if self.task != nil {
            taskNameLabel.text = task.name
            taskImageView.image = task.image
            isChecked = task.isChecked
            updateSelectionButtonAppearance()
        }
    }
    
    func updateSelectionButtonAppearance() {
        let imageName = isChecked ? "selected" : "unselected"
        isSelectedButton.setImage(UIImage(named: imageName), for: .normal)
    }
}
