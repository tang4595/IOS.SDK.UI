//
//  EmailOTPView.swift
//  AmaniStudio
//
//  Created by Deniz Can on 10.12.2023.
//

import Foundation
import UIKit
import Combine

class EmailOTPView: UIView {
  
  private var cancellables = Set<AnyCancellable>()
  private var viewModel: EmailOTPViewModel!
  private var completionHandler: (() -> Void)? = nil
  
  private lazy var titleText: UILabel = {
    let label = UILabel()
    label.text = "Verify Email Address"
    label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
    label.textColor = UIColor(hexString: "#20202F")
    return label
  }()
  
  private lazy var descriptionText: UILabel = {
    let label = UILabel()
    label.text = "We will send you a ‘one time PIN’ to reset your password"
    label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
    label.numberOfLines = 2
    label.textColor = UIColor(hexString: "#20202F")
    
    return label
  }()
  
  private lazy var emailLegend: UILabel = {
    let label = UILabel()
    label.text = "Email Adress"
    label.textColor = UIColor(hexString: "#20202F")
    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    label.numberOfLines = 1
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()
  
  private lazy var emailInput: RoundedTextInput = {
    let input = RoundedTextInput(
      placeholderText: "Enter your email address here",
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
      emailLegend, emailInput
    ])
    
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 6.0
    return stackView
  }()
  
  private lazy var mainStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      titleText,
      descriptionText,
      formView,
      submitButton,
    ])
    
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 0.0
    
    stackView.setCustomSpacing(16.0, after: titleText)
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
      name: NSNotification.Name("ai.amani.onError"),
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
  
  func bind(withViewModel viewModel: EmailOTPViewModel) {
    emailInput.setDelegate(delegate: self)
    
    emailInput.textPublisher
      .assign(to: \.email, on: viewModel)
      .store(in: &cancellables)
    
    viewModel.isEmailValidPublisher
      .sink(receiveValue: { [weak self] isValidEmail in
        if !isValidEmail {
          self?.emailInput.showError(message: "This email Address is wrong")
        } else {
          self?.emailInput.hideError()
        }
      }).store(in: &cancellables)
    
    viewModel.$state
      .sink { [weak self] state in
        switch state {
        case .loading:
          self?.submitButton.showActivityIndicator()
        case .success:
          DispatchQueue.main.async {
            if let handler = self?.completionHandler {
              handler()
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
      viewModel.submitEmailForOTP()
    }
    
    self.viewModel = viewModel
  }
  
  func setCompletion(handler: @escaping () -> Void) {
    self.completionHandler = handler
  }
  
  func setupErrorHandling() {
    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveError(_:)), name: Notification.Name("ai.amani.onError"), object: nil)
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
              self.emailInput.showError(message: message!)
            }
          }
        } else {
          DispatchQueue.main.async {
            self.emailInput.showError(message: "There is a problem with this email address")
          }
        }
      }
    }
  }
  
}

extension EmailOTPView: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    viewModel.submitEmailForOTP()
    emailInput.field.resignFirstResponder()
    return true
  }
}
