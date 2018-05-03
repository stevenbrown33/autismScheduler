//
//  UIHelper.swift
//  AutismScheduler
//
//  Created by Steven Brown on 5/2/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit

class UIHelper {
    static let shared = UIHelper()
    let defaultButtonCornerRadius: CGFloat = 20
    let primaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let secondaryColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
    let tertiaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
//    var gradientLayer: CAGradientLayer
//    let topColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//    let bottomColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
//
//    init() {
//        self.gradientLayer = CAGradientLayer()
//        self.gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
//        self.gradientLayer.locations = [0.0, 1.0]
    //    }
}

extension UIColor {
    public static var defaultBackgroundColor: UIColor = UIHelper.shared.primaryColor
    public static var defaultTextColor: UIColor = UIHelper.shared.secondaryColor
    public static var defaultButtonColor: UIColor = UIHelper.shared.secondaryColor
    public static var defaultButtonTextColor: UIColor = UIHelper.shared.primaryColor
    public static var defaultTintColor: UIColor = UIHelper.shared.secondaryColor
}
