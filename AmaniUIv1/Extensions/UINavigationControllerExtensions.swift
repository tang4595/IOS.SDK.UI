//
//  UINavigationControllerExtensions.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 14.10.2022.
//

import Foundation
import UIKit

extension UINavigationController {
  
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
  
}
