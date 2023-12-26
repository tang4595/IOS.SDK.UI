//
//  OTPViewController.swift
//  AmaniUI
//
//  Created by Deniz Can on 25.12.2023.
//

import Foundation
import UIKit

class OTPViewController: UIViewController {
  private var emailOTPEnabled = false
  private var phoneOTPEnabled = false
  private var emailOTPCompleted = false
  private var phoneOTPCompleted = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if (emailOTPEnabled) {
      startEmailFlow()
    } else if (phoneOTPEnabled) {
      startPhoneFlow()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationItem.hidesBackButton = true
  }
  
  func setup(emailEnabled: Bool, phoneEnabled: Bool) {
    emailOTPEnabled = emailEnabled
    phoneOTPEnabled = phoneEnabled
  }
  
  func startEmailFlow() {
    let emailOTPVC = EmailOTPScreenViewController()
    
    emailOTPVC.setCompletionHandler {
      if (self.phoneOTPEnabled) {
        self.startPhoneFlow()
      } else {
      // return to home.
      self.navigationController?.popToViewController(ofClass: HomeViewController.self, animated: true)
      }
    }
    
    DispatchQueue.main.async {
      self.navigationController?.pushViewController(emailOTPVC, animated: false)
    }
  }
  
  func startPhoneFlow() {
    let phoneOTPVC = PhoneOTPScreenViewController()
    
    phoneOTPVC.setCompletionHandler {
      if (self.phoneOTPEnabled) {
        self.startPhoneFlow()
      } else {
      // return to home.
      self.navigationController?.popToViewController(ofClass: HomeViewController.self, animated: true)
      }
    }
    
    DispatchQueue.main.async {
      self.navigationController?.pushViewController(phoneOTPVC, animated: false)
    }
  }
  
}
