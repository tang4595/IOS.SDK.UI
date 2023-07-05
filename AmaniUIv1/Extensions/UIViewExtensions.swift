//
//  File.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 6.09.2022.
//

import UIKit
/**
 This file consists all the extended features of a UIView
 */
extension UIView {
  
  /**
   This method used to add shadow on view
   - parameter shadowRadius: CGFloat
   - parameter shadowColor: UIColor
   - parameter shadowOpacity: Float?
   - parameter borderColor: UIColor?
   - parameter borderWidth: CGFloat?
   - parameter cornerRadious: CGFloat?
   */
  func addShadowWithBorder(shadowRadius: CGFloat, shadowColor: UIColor, shadowOpacity: Float? = 0, borderColor: UIColor? = nil, borderWidth: CGFloat? = 0, cornerRadious: CGFloat? = 0 ) {
    self.layoutIfNeeded()
    self.layer.masksToBounds = false
    self.layer.shadowColor = shadowColor.cgColor
    self.layer.shadowOpacity = shadowOpacity ?? 0.1
    self.layer.shadowOffset = CGSize.zero
    self.layer.shadowRadius = shadowRadius
    self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: shadowRadius).cgPath
    self.layer.shouldRasterize = true
    self.layer.rasterizationScale = UIScreen.main.scale
    self.layer.borderColor = borderColor?.cgColor
    self.layer.borderWidth = borderWidth ?? 0
    self.layer.cornerRadius = cornerRadious ?? 0
    self.clipsToBounds = true
  }
  
  func addCornerRadiousWith(radious: CGFloat) {
    self.layer.cornerRadius = radious
    self.clipsToBounds = true
  }
  
  func addBorder(borderWidth: CGFloat, borderColor: CGColor) {
    self.layer.borderWidth = borderWidth
    self.layer.borderColor = borderColor
  }
}
