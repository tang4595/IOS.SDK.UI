//
//  PasswordResetOTPViewController.swift
//  AmaniStudio
//
//  Created by Deniz Can on 10.12.2023.
//

import Foundation
import UIKit

class PasswordResetViewController: BaseViewController {
  
  override func viewDidLoad() {
    let passwordResetOTPView = PasswordResetOTPView()
    let passwordResetOTPViewModel = PasswordResetOTPViewModel()
    
    passwordResetOTPView.bind(withViewModel: passwordResetOTPViewModel)
    
    passwordResetOTPView.setCancelButtonHandler {[weak self] in
      guard let self = self else {return}
      self.navigationController?.popViewController(animated: true)
    }
    
    passwordResetOTPView.setSubmitButtonHandler {[weak self] in
      let checkMailViewController = CheckMailViewController()
      // TODO: Check from state from viewmodel
      self?.navigationController?.pushViewController(
        checkMailViewController,
        animated: true
      )
    }
    
    view.backgroundColor = UIColor(hex: "#EEF4FA")!
    addPoweredByIcon()
    
    contentView.addSubview(passwordResetOTPView)
    passwordResetOTPView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      passwordResetOTPView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      passwordResetOTPView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
      passwordResetOTPView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
      
    ])
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    
  }
  
}
