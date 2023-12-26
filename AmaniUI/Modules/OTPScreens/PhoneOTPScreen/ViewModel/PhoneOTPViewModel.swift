//
//  PhoneOTPViewModel.swift
//  AmaniUI
//
//  Created by Deniz Can on 26.12.2023.
//

import Foundation
import Combine
import AmaniSDK

class PhoneOTPViewModel {
  private let customerInfo = Amani.sharedInstance.customerInfo()
  enum ViewState {
    case loading
    case success
    case failed
    case none
  }
  
  @Published var phone = ""
  @Published var state: ViewState = .none
  
  var isEmailValidPublisher: AnyPublisher<Bool, Never> {
    $phone.debounce(for: 0.5, scheduler: RunLoop.main)
      .map { _ in self.isValidPhone() }
      .eraseToAnyPublisher()
  }
  
  func submitPhoneForOTP() {
    state = .loading
    customerInfo.setPhone(phone: phone)
    customerInfo.upload(
      location: AmaniUI.sharedInstance.location) { [weak self] _ in
        guard let self = self else {return}
        
        self.customerInfo.requestPhoneOTPCode { success in
          if let success = success {
            self.state = .success
          } else {
            self.state = .failed
          }
        }
      }
  }
  
  private func isValidPhone() -> Bool {
//    if self.email == "" { return true }
//    
//    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
//    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
//    
//    return emailPredicate.evaluate(with: self.email)
    // TODO: Phone Validations for multiple countries?
    return true
  }
  
  
}
