//
//  CheckMailView.swift
//  AmaniStudio
//
//  Created by Deniz Can on 11.12.2023.
//

import Foundation
import UIKit
import Combine

class CheckMailView: UIView {
  // MARK: Info Section
  private var viewModel: CheckMailViewModel!
  private var cancellables = Set<AnyCancellable>()
  private var completionHandler: (() -> Void)!
  
  private lazy var titleText: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 22.0, weight: .bold)
    label.text = "Check your Email"
    label.textColor = UIColor(hexString: "#20202F")
    return label
  }()
  
  private lazy var titleDescription: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
    label.text = "Please check your inbox and enter the OTP   (One Time PIN) you received to create a new password"
    label.numberOfLines = 2
    label.lineBreakMode = .byTruncatingMiddle
    label.textColor = UIColor(hexString: "#20202F")
    return label
  }()
  
  private lazy var titleStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      titleText,
      titleDescription
    ])
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.distribution = .equalSpacing
    stackView.spacing = 12.0
    return stackView
  }()
  
  // MARK: Form Area
  private lazy var otpLegendRow: UIStackView = {
    let label = UILabel()
    label.text = "OTP (One Time PIN you received)"
    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    label.textColor = UIColor(hexString: "#20202F")
    
    let stackView = UIStackView(arrangedSubviews: [label])
    return stackView
  }()
  
  private lazy var otpInput: RoundedTextInput = {
    let input = RoundedTextInput(
      placeholderText: "",
      borderColor: UIColor(hexString: "#515166"),
      placeholderColor: UIColor(hexString: "#C0C0C0"),
      isPasswordToggleEnabled: false,
      keyboardType: .numberPad
    )
    return input
  }()
  
  
  private lazy var formStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      otpLegendRow,
      otpInput,
    ])
    
    return stackView
  }()
  
  // MARK: Form Buttons
  let submitButton: RoundedButton = {
    let button = RoundedButton(
      withTitle: "Verify Email",
      withColor: UIColor(hexString: "#EA3365")
    )
    return button
  }()
  
  private lazy var mainStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      titleStackView,
      formStackView,
      submitButton,
    ])
    stackView.axis = .vertical
    stackView.spacing = 0.0
    stackView.distribution = .fill
    stackView.setCustomSpacing(32.0, after: titleStackView)
    stackView.setCustomSpacing(54.0, after: formStackView)
    return stackView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupUI() {
    addSubview(mainStackView)
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: topAnchor),
      mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }
  
  func bind(withViewModel viewModel: CheckMailViewModel) {
    otpInput.setDelegate(delegate: self)
    
    otpInput.textPublisher
      .assign(to: \.otp, on: viewModel)
      .store(in: &cancellables)
    
    viewModel.isOTPValidPublisher.sink(receiveValue: { [weak self] isValidOTP in
        if !isValidOTP {
          self?.otpInput.showError(message: "This email Address is wrong")
        } else {
          self?.otpInput.hideError()
        }
      }).store(in: &cancellables)
    
    viewModel.$state
      .sink { [weak self] state in
        switch state {
        case .loading:
          self?.submitButton.showActivityIndicator()
        case .success:
          self?.completionHandler()
          self?.submitButton.hideActivityIndicator()
        case .failed:
          self?.submitButton.hideActivityIndicator()
        case .none:
          break
        }
      }
      .store(in: &cancellables)
    
    submitButton.bind {
      viewModel.submitOTP()
    }
    
    self.viewModel = viewModel
  }
  
  func setCompletionHandler(_ handler: @escaping (() -> Void)) {
    self.completionHandler = handler
  }
  
}

// MARK: TextFieldDelegate
extension CheckMailView: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.viewModel.submitOTP()
    return true
  }
  
}
