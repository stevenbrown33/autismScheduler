//
//  ActivityTableViewCell.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/20/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var isSelectedButton: UIButton!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityImageView: UIImageView!
    var activity: Activity? {
        didSet {
            updateViews()
        }
    }
    // MARK: - Actions
    @IBAction func isSelectedButtonTapped(_ sender: UIButton) {
    }
    
    func updateViews() {
        guard let activity = activity else { return }
        activityNameLabel.text = activity.name
        activityImageView.image = activity.image
    }
    
}
