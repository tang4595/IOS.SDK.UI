//
//  ProfileInfoView.swift
//  AmaniUI
//
//  Created by Deniz Can on 22.01.2024.
//

import AmaniSDK
import Combine
import Foundation
import UIKit

class ProfileInfoView: UIView {
  private var cancellables = Set<AnyCancellable>()
  private var viewModel: ProfileInfoViewModel!
  private var completionHandler: (() -> Void)?
  private let nameValidationString: String = "Name should not exceed 64 characters"
  private let surnameValidationString: String = "Surname should not exceed 32 characters"

  // MARK: Info section

  private lazy var titleText: UILabel = {
    let label = UILabel()
    label.text = "Fill the details"
    label.font = UIFont.systemFont(ofSize: 24.0, weight: .bold)
    label.textColor = UIColor(hexString: "#2020F")
    return label
  }()

  // MARK: Form Area

  private lazy var nameLegend: UILabel = {
    let label = UILabel()
    label.text = "Name"
    label.textColor = UIColor(hexString: "#2020F")
    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    label.numberOfLines = 1
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()

  private lazy var nameInput: RoundedTextInput = {
    let input = RoundedTextInput(
      placeholderText: "Enter your name",
      borderColor: UIColor(hexString: "#515166"),
      placeholderColor: UIColor(hexString: "#C0C0C0"),
      isPasswordToggleEnabled: false,
      keyboardType: .default
    )
    return input
  }()

  private lazy var surnameLegend: UILabel = {
    let label = UILabel()
    label.text = "Surname"
    label.textColor = UIColor(hexString: "#2020F")
    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    label.numberOfLines = 1
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()

  private lazy var surnameInput: RoundedTextInput = {
    let input = RoundedTextInput(
      placeholderText: "Enter your surname",
      borderColor: UIColor(hexString: "#515166"),
      placeholderColor: UIColor(hexString: "#C0C0C0"),
      isPasswordToggleEnabled: false,
      keyboardType: .default
    )
    return input
  }()

  private lazy var birthdateLabel: UILabel = {
    let label = UILabel()
    label.text = "Date of Birth"
    label.textColor = UIColor(hexString: "#2020F")
    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    label.numberOfLines = 1
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()

  private lazy var birthdateInput: RoundedTextInput = {
    let input = RoundedTextInput(
      placeholderText: "XX/XX/XXXX",
      borderColor: UIColor(hexString: "#515166"),
      placeholderColor: UIColor(hexString: "#C0C0C0"),
      isPasswordToggleEnabled: false,
      keyboardType: .default
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
      nameLegend, nameInput,
      surnameLegend, surnameInput,
      birthdateLabel, birthdateInput,
    ])

    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 6.0

    return stackView
  }()

  private lazy var mainStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      titleText,
      formView,
      submitButton,
    ])

    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 0.0

    stackView.setCustomSpacing(24.0, after: titleText)
    stackView.setCustomSpacing(100.0, after: formView)

    return stackView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    setupErrorHandling()
  }

  // MARK: Initializers

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

  // MARK: UI Setup

  func setupUI() {
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(mainStackView)
    NSLayoutConstraint.activate([
      mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      mainStackView.topAnchor.constraint(equalTo: topAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  func setupErrorHandling() {
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(didReceiveError(_:)),
        name: Notification.Name(
          AppConstants.AmaniDelegateNotifications.onError.rawValue
        ),
        object: nil)
  }

  @objc func didReceiveError(_ notification: Notification) {
    if let errorObjc = notification.object as? [String: Any] {
      let type = errorObjc["type"] as! String
      let errors = errorObjc["errors"] as! [[String: String]]
      if type == "customer_error" {
        print(errors)
      }
    }
  }

  func bind(
    withViewModel viewModel: ProfileInfoViewModel
  ) {
    nameInput.setDelegate(delegate: self)
    surnameInput.setDelegate(delegate: self)
    birthdateInput.setDelegate(delegate: self)

    nameInput.textPublisher
      .compactMap { $0 }
      .assign(to: \.name, on: viewModel)
      .store(in: &cancellables)

    surnameInput.textPublisher
      .compactMap { $0 }
      .assign(to: \.surname, on: viewModel)
      .store(in: &cancellables)

    birthdateInput.textPublisher
      .compactMap { $0 }
      .assign(to: \.birthDay, on: viewModel)
      .store(in: &cancellables)

    submitButton.bind {
      viewModel.submitForm()
    }

    viewModel.isNameValidPublisher
      .sink(receiveValue: { [weak self] isNameValid in
        if !isNameValid {
          self?.nameInput.showError(message: "Given name is too long")
        } else {
          self?.nameInput.hideError()
        }
      }).store(in: &cancellables)

    viewModel.isSurnameValidPublisher
      .sink(receiveValue: { [weak self] isNameValid in
        if !isNameValid {
          self?.nameInput.showError(message: "Given surname is too long")
        } else {
          self?.nameInput.hideError()
        }
      }).store(in: &cancellables)

    viewModel.isNameValidPublisher
      .sink(receiveValue: { [weak self] isNameValid in
        if !isNameValid {
          self?.nameInput.showError(message: "Given name is too long")
        } else {
          self?.nameInput.hideError()
        }
      }).store(in: &cancellables)

    viewModel.isBdayValidPublisher
      .sink(receiveValue: { [weak self] isBdayValid in
        if !isBdayValid {
          self?.birthdateInput.showError(message: "Invalid date of birth")
        } else {
          self?.birthdateInput.hideError()
        }
      }).store(in: &cancellables)
    
    viewModel.$state
      .sink { [weak self] state in
        switch state {
        case .loading:
          self?.submitButton.showActivityIndicator()
        case .success:
          DispatchQueue.main.async {
            if let completionHandler = self?.completionHandler {
              completionHandler()
            }
          }
        case .failed:
          self?.submitButton.hideActivityIndicator()
        case .none:
          break
        }
      }.store(in: &cancellables)

    self.viewModel = viewModel
  }

  func setCompletion(handler: @escaping () -> Void) {
    completionHandler = handler
  }

  private func formatAsDate(for input: String) -> String {
    // Assuming the date format is MM / DD / YYYY
    var formattedText = ""

    for (index, character) in input.enumerated() {
      if index == 2 || index == 4 {
        formattedText += "/\(character)"
      } else {
        formattedText.append(character)
      }

      if formattedText.count > 10 {
        formattedText = String(formattedText.prefix(10))
      }
    }

    return formattedText
  }
}

extension ProfileInfoView: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == nameInput {
      surnameInput.becomeFirstResponder()
    } else if textField == surnameInput {
      birthdateInput.becomeFirstResponder()
    } else if textField == birthdateInput {
      viewModel.submitForm()
      return true
    }
    return true
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard textField == birthdateInput.field else {
      return true
    }

    guard let text = textField.text else {
      return true
    }

    let cleanedText = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let rangeOfTextToReplace = Range(range, in: cleanedText) ?? cleanedText.endIndex ..< cleanedText.endIndex

    // Check if it's a backspace press
    if string.isEmpty {
      var newText = cleanedText
      if text.count == 1 {
        newText = ""
        textField.text = newText
        viewModel.birthDay = newText
        return false
      }

      newText.remove(at: newText.index(before: rangeOfTextToReplace.lowerBound))
      newText = formatAsDate(for: newText)
      textField.text = newText

      return false
    }

    var newText = cleanedText
    newText.replaceSubrange(rangeOfTextToReplace, with: string)
    newText = formatAsDate(for: newText)
    textField.text = newText
    viewModel.birthDay = newText
    return false
  }
}
