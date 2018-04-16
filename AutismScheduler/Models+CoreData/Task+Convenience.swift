//
//  Task+Convenience.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

extension Task {
    
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    @discardableResult convenience init(name: String,
                                        image: UIImage? = nil,
                                        isActive: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.name = name
        if let image = image {
            let imageData = UIImageJPEGRepresentation(image, 1)
            self.imageData = imageData
        }
        self.isActive = isActive
    }
}
