//
//  AssignedTaskTableViewCell.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/25/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class AssignedTaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskImageView: UIImageView!
    var task: Task?
}
