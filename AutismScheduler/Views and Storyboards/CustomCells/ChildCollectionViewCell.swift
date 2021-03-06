//
//  ChildCollectionViewCell.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class ChildCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var childImageView: UIImageView!
    @IBOutlet weak var childNameLabel: UILabel!
    var child: Child? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let child = child else { return }
        childNameLabel.text = child.name
        childImageView.image = child.image
    }
    
}
