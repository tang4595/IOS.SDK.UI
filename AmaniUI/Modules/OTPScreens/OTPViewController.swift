//
//  OTPViewController.swift
//  AmaniUI
//
//  Created by Deniz Can on 25.12.2023.
//

import Foundation
import UIKit
import AmaniSDK

class OTPViewController: UIViewController {
  private var emailOTPEnabled = false
  private var phoneOTPEnabled = false
  private var emailOTPCompleted = false
  private var phoneOTPCompleted = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let customer = Amani.sharedInstance.customerInfo().getCustomer()
    emailOTPCompleted = customer.emailVerified!
    phoneOTPCompleted = customer.phoneVerified!
    
    if (emailOTPCompleted && phoneOTPCompleted) {
      self.navigationController?.popToViewController(ofClass: HomeViewController.self, animated: false)
      return
    }
    
    
    if (emailOTPEnabled && !emailOTPCompleted) {
      startEmailFlow()
    } else if (phoneOTPEnabled && !phoneOTPCompleted) {
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
    
    emailOTPVC.setCompletionHandler {[weak self] in
      guard let self = self else { return }
      
      if (self.phoneOTPEnabled && !self.phoneOTPCompleted) {
        self.startPhoneFlow()
      } else {
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
      // return to home.
      self.navigationController?.popToViewController(ofClass: HomeViewController.self, animated: true)
    }
    
    DispatchQueue.main.async {
      self.navigationController?.pushViewController(phoneOTPVC, animated: false)
    }
  }
  
}
