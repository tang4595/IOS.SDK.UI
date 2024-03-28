//
//  PhoneOTPView.swift
//  AmaniUI
//
//  Created by Deniz Can on 26.12.2023.
//

import Foundation
import UIKit
import Combine
import AmaniSDK

class PhoneOTPView: UIView {
  
  private var cancellables = Set<AnyCancellable>()
  private var viewModel: PhoneOTPViewModel!
  private var completion: (() -> Void)? = nil
  
  private lazy var descriptionText: UILabel = {
    let label = UILabel()
    label.text = "We will send a ‘one time PIN’ to your phone number for verification"
    label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
    label.numberOfLines = 2
    label.textColor = UIColor(hexString: "#20202F")
    
    return label
  }()
  
  private lazy var phoneLegend: UILabel = {
    let label = UILabel()
    label.text = "Phone Number"
    label.textColor = UIColor(hexString: "#20202F")
    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    label.numberOfLines = 1
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()
  
  private lazy var phoneInput: RoundedTextInput = {
    let input = RoundedTextInput(
      placeholderText: "Enter your phone here",
      borderColor: UIColor(hexString: "#515166"),
      placeholderColor: UIColor(hexString: "#C0C0C0"),
      isPasswordToggleEnabled: false,
      keyboardType: .emailAddress
    )
    return input
  }()
  
  private lazy var submitButton: RoundedButton = {
    let button = RoundedButton(
      withTitle: "Continue",
      withColor: UIColor(hexString: "#EA3365")
    )
    return button
  }()
  
  private lazy var formView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      phoneLegend, phoneInput
    ])
    
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 6.0
    return stackView
  }()
  
  private lazy var mainStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      descriptionText,
      formView,
      submitButton,
    ])
    
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 0.0
    
    stackView.setCustomSpacing(80.0, after: descriptionText)
    stackView.setCustomSpacing(150.0, after: formView)
    
    
    return stackView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    setupErrorHandling()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    NotificationCenter.default.removeObserver(
      self,
      name: NSNotification.Name(
        AppConstants.AmaniDelegateNotifications.onError.rawValue
      ),
      object: nil
    )
  }
  
  func setupUI() {
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(mainStackView)
    NSLayoutConstraint.activate([
      mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      mainStackView.topAnchor.constraint(equalTo: topAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  func bind(
    withViewModel viewModel: PhoneOTPViewModel,
    withDocument document: DocumentVersion?
  ) {
    phoneInput.setDelegate(delegate: self)
    
    phoneInput.textPublisher
      .assign(to: \.phone, on: viewModel)
      .store(in: &cancellables)
    
    viewModel.isEmailValidPublisher
      .sink(receiveValue: { [weak self] isValidEmail in
        if !isValidEmail {
          self?.phoneInput.showError(message: "This email Address is wrong")
        } else {
          self?.phoneInput.hideError()
        }
      }).store(in: &cancellables)
    
    viewModel.$state
      .sink { [weak self] state in
        switch state {
        case .loading:
          self?.submitButton.showActivityIndicator()
        case .success:
          DispatchQueue.main.async {
            if let completion = self?.completion {
              completion()
            }
          }
          self?.submitButton.hideActivityIndicator()
        case .failed:
          self?.submitButton.hideActivityIndicator()
        case .none:
          break
        }
      }
      .store(in: &cancellables)
    
    submitButton.bind {
      viewModel.submitPhoneForOTP()
    }
    
    self.viewModel = viewModel
    if let doc = document {
      setTextsFrom(document: doc)
    }
  }
  
  func setCompletion(handler: @escaping () -> Void) {
    self.completion = handler
  }
  
  func setupErrorHandling() {
    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(_:)), name: Notification.Name(AppConstants.AmaniDelegateNotifications.onError.rawValue), object: nil)
  }
  
  @objc func didReceiveError(_ notification: Notification) {
    //                                            type, errors
    if let errorObjc = notification.object as? [String: Any] {
      let type = errorObjc["type"] as! String
      let errors = errorObjc["errors"] as! [[String: String]]
      if (type == "customer_error") {
        if let errorMessageJson = errors.first?["errorMessage"] {
          if let detail = try? JSONDecoder()
            .decode(
              [String: String].self,
              from: errorMessageJson.data(using: .utf8)!
            ) {
            let message = detail["detail"]
            DispatchQueue.main.async {
              self.phoneInput.showError(message: message!)
            }
          }
        } else {
          DispatchQueue.main.async {
            self.phoneInput.showError(message: "There is a problem with this phone number")
          }
        }
      }
    }
  }
  
  private func setTextsFrom(document: DocumentVersion) {
    if let step = document.steps?.first {
      // FIXME: No button text
      DispatchQueue.main.async {
        self.submitButton.titleLabel?.text = document.nextButtonText
        self.descriptionText.text = step.captureDescription
        self.phoneLegend.text = document.phoneHint
      }
    }
  }
  
}

extension PhoneOTPView: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    viewModel.submitPhoneForOTP()
    phoneInput.field.resignFirstResponder()
    return true
  }
}
