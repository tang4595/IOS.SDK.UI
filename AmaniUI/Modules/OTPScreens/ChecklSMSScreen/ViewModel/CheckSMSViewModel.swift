//
//  CheckSMSViewModel.swift
//  AmaniUI
//
//  Created by Deniz Can on 26.12.2023.
//

import Foundation
import Combine
import AmaniSDK

class CheckSMSViewModel {
  private let customerInfo = Amani.sharedInstance.customerInfo()
  
  enum ViewState {
    case loading
    case success
    case failed
    case none
  }
  
  @Published var otp = ""
  @Published var state: ViewState = .none
  
  var isOTPValidPublisher: AnyPublisher<Bool, Never> {
    $otp.debounce(for: 0.5, scheduler: RunLoop.main)
      .map { _ in self.isValidOTPCode() }
      .eraseToAnyPublisher()
  }
  
  func submitOTP() {
    guard !self.isValidOTPCode() else { return }
    
    self.state = .loading
    customerInfo.submitEmailOTP(code: otp) {[weak self] success in
      guard let self = self else { return }
      if let success = success, success {
        self.state = .success
      } else {
        self.state = .failed
      }
    }
  }
  
  func resendOTP() {
    customerInfo.requestEmailOTPCode {_ in
      // NO-OP?
      // error handling maybe?
    }
  }
  
  private func isValidOTPCode() -> Bool {
    // initial state
    if otp == "" { return true }
    let numericCharacterSet = CharacterSet.decimalDigits
    guard otp.rangeOfCharacter(from: numericCharacterSet.inverted) == nil else {
      return false
    }
    
    return otp.count == 7
  }
  
}
