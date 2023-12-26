//
//  PhoneOTPViewController.swift
//  AmaniUI
//
//  Created by Deniz Can on 26.12.2023.
//

import Foundation
import UIKit

class PhoneOTPScreenViewController: KeyboardAvoidanceViewController {
  let phoneOTPView = PhoneOTPView()
  let phoneOTPViewModel = PhoneOTPViewModel()
  private var handler: (() -> Void)? = nil
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if isMovingFromParent {
      // Exit directly to the user's app
      AmaniUI.sharedInstance.popViewController()
    }
  }
  
  override func viewDidLoad() {
    phoneOTPView.bind(withViewModel: phoneOTPViewModel)
    
    phoneOTPView.setSubmitButtonHandler {[weak self] in
      let checkSMSViewController = CheckSMSViewController()
      
      checkSMSViewController.setupCompletionHandler {
        if let handler = self?.handler {
          handler()
        }
      }
      
      self?.navigationController?.pushViewController(
        checkSMSViewController,
        animated: true
      )
    }
    
    view.backgroundColor = UIColor(hexString: "#EEF4FA")
    addPoweredByIcon()
    
    contentView.addSubview(phoneOTPView)
    phoneOTPView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      phoneOTPView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      phoneOTPView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
      phoneOTPView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
    ])
  }
  
  func setCompletionHandler(_ handler: @escaping (() -> Void)) {
    self.handler = handler
  }
  
}
