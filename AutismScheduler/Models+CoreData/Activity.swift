//
//  Activity.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/17/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

class Activity2 {
    private let nameKey = "name"
    private let imageKey = "image"
    static let typeKey = "Activity"
    
    let name: String
    let image: UIImage?
    weak var child: Child?
    var cloudKitRecordID: CKRecordID?
    
    init(name: String, image: UIImage?, child: Child?) {
        self.name = name
        self.image = image
        self.child = child
    }
}
