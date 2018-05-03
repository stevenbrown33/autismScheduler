//
//  ActivityTableViewCell.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/20/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

protocol ActivityTableViewCellDelegate {
    func selectionButtonTapped(_ sender: ActivityTableViewCell)
}

class ActivityTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var isSelectedButton: UIButton!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityImageView: UIImageView!
    var delegate: ActivityTableViewCellDelegate?
    var isChecked = false {
        didSet {
            updateSelectionButtonAppearance()
        }
    }
    var activity: Activity? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Actions
    @IBAction func isSelectedButtonTapped(_ sender: UIButton) {
        delegate?.selectionButtonTapped(self)
    }
    
    func updateViews() {
        guard let activity = activity else { return }
        if self.activity != nil {
            activityNameLabel.text = activity.name
            activityNameLabel.textColor = .defaultTextColor
            activityImageView.image = activity.image
            isSelectedButton.tintColor = .defaultTintColor
            isChecked = activity.isChecked
            updateSelectionButtonAppearance()
        }
    }
    
    func updateSelectionButtonAppearance() {
        let selectedImage = UIImage(named: "selected")?.withRenderingMode(.alwaysTemplate)
        let unselectedImage = UIImage(named: "unselected")?.withRenderingMode(.alwaysTemplate)
        let imageName = isChecked ? selectedImage : unselectedImage
        isSelectedButton.setImage(imageName, for: .normal)
        isSelectedButton.tintColor = .defaultTintColor
    }
}
