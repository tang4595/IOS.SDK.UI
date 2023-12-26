//
//  EmailOTPScreenViewController.swift
//  AmaniStudio
//
//  Created by Deniz Can on 10.12.2023.
//

import Foundation
import UIKit

class EmailOTPScreenViewController: KeyboardAvoidanceViewController {
  let emailOTPView = EmailOTPView()
  let emailOTPViewModel = EmailOTPViewModel()
  private var handler: (() -> Void)? = nil
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if isMovingFromParent {
      // Exit directly to the user's app
      AmaniUI.sharedInstance.popViewController()
    }
  }
  
  override func viewDidLoad() {
    emailOTPView.bind(withViewModel: emailOTPViewModel)
    
    emailOTPView.setSubmitButtonHandler {[weak self] in
      let checkMailViewController = CheckMailViewController()
      
      checkMailViewController.setupCompletionHandler {
        if let handler = self?.handler {
          handler()
        }
      }
      
      self?.navigationController?.pushViewController(
        checkMailViewController,
        animated: true
      )
    }
    
    view.backgroundColor = UIColor(hexString: "#EEF4FA")
    addPoweredByIcon()
    
    contentView.addSubview(emailOTPView)
    emailOTPView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      emailOTPView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      emailOTPView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
      emailOTPView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
    ])
  }
  
  func setCompletionHandler(_ handler: @escaping (() -> Void)) {
    self.handler = handler
  }
  
}
