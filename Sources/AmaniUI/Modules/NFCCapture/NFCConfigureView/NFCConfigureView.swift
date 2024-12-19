//
//  NFCConfigureView.swift
//  Pods
//
//  Created by Bedri Doğan on 12.12.2024.
//

import Foundation
import UIKit
import AmaniSDK

class NFCConfigureView: UIView {
    // MARK: Form Area
  private var descriptionLabel = UILabel()
  private var documentNumbers = UILabel()
  private var documentNoInput = RoundedTextInput()
  private var dateOfExpiryDate = UILabel()
  private var expirydateInput = RoundedTextInput()
  private var birthdateLabel = UILabel()
  private var birthdateInput = RoundedTextInput()
  private var submitButton = RoundedButton()
  private var formView = UIStackView()
  private var mainStackView = UIStackView()
  private var amaniLogo = UIImageView()
  var setButtonCb: ((NviModel) async -> Void)?
  
  private var newDocumentNo: String?
  private var newbirthDate: String?
  private var newExpiryDate: String?
  
  private lazy var expiryDataPicker: UIDatePicker = {
    let picker = UIDatePicker()
    picker.datePickerMode = .date
    return picker
  }()
  
  private lazy var birthDatePicker: UIDatePicker = {
    let picker = UIDatePicker()
    picker.datePickerMode = .date
    return picker
  }()
  
  var nviData: NviModel?
  var appConfig: AppConfigModel? {
    didSet {
      guard let config = appConfig else { return }
      setNFCFormUI()
      setupDatePicker()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
   
   
  }
  
  deinit {
    
  }

  
  required init?(coder: NSCoder) {
  
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    endEditing(true)
  }
 
  
  private func setupDatePicker() {
      // Create the date picker
    expiryDataPicker.datePickerMode = .date
    expiryDataPicker.locale = .current

    birthDatePicker.datePickerMode = .date
    birthDatePicker.locale = .current

    expirydateInput.field.inputView = expiryDataPicker
    birthdateInput.field.inputView = birthDatePicker
      // Handle date picker value changes
    expiryDataPicker.addTarget(self, action: #selector(expiryDataPickerValueChanged(_:)), for: .valueChanged)
    birthDatePicker.addTarget(self, action: #selector(birthDatePickerValueChanged(_:)), for: .valueChanged)
    
  }
  
  @objc private func birthDatePickerValueChanged(_ sender: UIDatePicker) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyMMdd"
    let selectedDate = dateFormatter.string(from: sender.date)
    self.newbirthDate = selectedDate
  }
  
  @objc private func expiryDataPickerValueChanged(_ sender: UIDatePicker) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyMMdd"
    let selectedDate = dateFormatter.string(from: sender.date)
    self.newExpiryDate = selectedDate
  }
  
  @objc private func birthdateInputTapped() {
   
    birthdateInput.field.resignFirstResponder()
  }
  
  @objc private func expiryDateInputTapped() {
    expirydateInput.field.resignFirstResponder()
  }
  
  @objc private func dismissBirthDatePicker() {
    birthdateInput.field.resignFirstResponder()
  }
  
  @objc private func dissmissExpiryDatePicker() {
    expirydateInput.field.resignFirstResponder()
  }
  
  @objc private func tapSubmitButton(_ sender: UIButton) {
    debugPrint("submit button basıldı")
    var nvi: NviModel = AmaniUI.sharedInstance.nviData!
    if newDocumentNo != nil {
      nvi.documentNo = self.newDocumentNo
    }
    if newbirthDate != nil {
      nvi.dateOfBirth = self.newbirthDate
    }
    if newExpiryDate != nil {
      nvi.dateOfExpire = self.newExpiryDate
    }
    Task {
      await setButtonCb!(nvi)
    }
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
  
  func setTextsFrom(nvi: NviModel?) {
    
    DispatchQueue.main.async {
      self.documentNoInput.field.text = nvi?.documentNo ?? ""
      
      if let dateOfBirth = nvi?.dateOfBirth,
         let birthDate = self.dateFormatter(dateString: dateOfBirth) {
        self.birthDatePicker.date = birthDate
      }
      
      if let dateOfExpire = nvi?.dateOfExpire,
         let expiryDate = self.dateFormatter(dateString: dateOfExpire) {
        self.expiryDataPicker.date = expiryDate
      }
    }
  }
  
  private func dateFormatter(dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyMMdd"
    return dateFormatter.date(from: dateString)!
  }
  
//  private func toggleTextInputs(isEnabled: Bool = true) {
//    DispatchQueue.main.async {
//      self.documentNoInput.field.isEnabled = isEnabled
//      self.expirydateInput.field.isEnabled = isEnabled
//      self.birthdateInput.field.isEnabled = isEnabled
//    }
//  }
//  
//  private func clearTextInputs() {
//    DispatchQueue.main.async {
//      self.documentNoInput.field.text = ""
//      self.expirydateInput.field.text = ""
//      self.birthdateInput.field.text = ""
//    }
//  }
  
}

extension NFCConfigureView {
  private func setNFCFormUI() {
    backgroundColor =  UIColor(hexString: appConfig?.generalconfigs?.appBackground ?? "#EEF4FA")
    self.submitButton.addTarget(self, action: #selector(tapSubmitButton(_:)), for: .touchUpInside)
    
    self.descriptionLabel.text = "Please check your information and re-edit if needed"
    self.descriptionLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    self.descriptionLabel.numberOfLines = 1
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    self.descriptionLabel.textAlignment = .center
    
    
    self.documentNumbers.text = "Document Numbers"
    self.documentNumbers.textColor = UIColor(hexString: "#2020F")
    self.documentNumbers.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    self.documentNumbers.numberOfLines = 1
    self.documentNumbers.setContentCompressionResistancePriority(.required, for: .vertical)
    
    self.documentNoInput = RoundedTextInput(
      placeholderText: "",
      borderColor: UIColor(hexString: "#515166"),
      placeholderColor: UIColor(hexString: "#C0C0C0"),
      isPasswordToggleEnabled: false,
      keyboardType: .default
    )
    
    self.dateOfExpiryDate.text = "Date of Expiry"
    self.dateOfExpiryDate.textColor = UIColor(hexString: "#2020F")
    self.dateOfExpiryDate.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    self.dateOfExpiryDate.numberOfLines = 1
    self.dateOfExpiryDate.setContentCompressionResistancePriority(.required, for: .vertical)
    
    self.expirydateInput = RoundedTextInput(
      placeholderText: "",
      borderColor: UIColor(hexString: "#515166"),
      placeholderColor: UIColor(hexString: "#C0C0C0"),
      isPasswordToggleEnabled: false,
      keyboardType: .numberPad
    )
    
    self.birthdateLabel.text = "Date of Birth"
    self.birthdateLabel.textColor = UIColor(hexString: "#2020F")
    self.birthdateLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    self.birthdateLabel.numberOfLines = 1
    self.birthdateLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    
    self.birthdateInput = RoundedTextInput(
      placeholderText: "",
      borderColor: UIColor(hexString: "#515166"),
      placeholderColor: UIColor(hexString: "#C0C0C0"),
      isPasswordToggleEnabled: false,
      keyboardType: .numberPad
    )
    self.submitButton.translatesAutoresizingMaskIntoConstraints = false
    
    submitButton.setTitleColor(UIColor(hexString: appConfig?.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
    submitButton.backgroundColor = UIColor(hexString: appConfig?.generalconfigs?.primaryButtonBackgroundColor ?? ThemeColor.whiteColor.toHexString())
    submitButton.addCornerRadiousWith(radious: CGFloat(appConfig?.generalconfigs?.buttonRadius ?? 10))
    submitButton.setTitle(appConfig?.generalconfigs?.continueText ?? "Devam", for: .normal)
//    let color = UIColor(hexString: appConfig?.generalconfigs?.primaryButtonBackgroundColor ?? "#EA3365")
  
//    
//    self.submitButton.setTitle(appConfig?.generalconfigs?.continueText ?? "Continue", for: .normal)
//    self.submitButton.setTitleColor(.white, for: .normal)
//    self.submitButton.backgroundColor = color
//    
//    self.submitButton.layer.borderColor = color.cgColor
//    self.submitButton.layer.cornerRadius = 24.0
//    
//    self.submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
//    self.submitButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    let textColor = appConfig?.generalconfigs?.appFontColor ?? "ffffff"
    self.amaniLogo = UIImageView(image: UIImage(named: "ic_poweredBy", in: AmaniUI.sharedInstance.getBundle(), with: nil)?.withRenderingMode(.alwaysTemplate))
    self.amaniLogo.translatesAutoresizingMaskIntoConstraints = false
    self.amaniLogo.contentMode = .scaleAspectFit
    self.amaniLogo.clipsToBounds = true
    self.amaniLogo.tintAdjustmentMode = .normal
    self.amaniLogo.tintColor = UIColor(hexString: textColor)
    
    
    self.formView = UIStackView(arrangedSubviews: [
      descriptionLabel, documentNumbers, documentNoInput,
      dateOfExpiryDate, expirydateInput,
      birthdateLabel, birthdateInput,
    ])
    
    self.formView.axis = .vertical
    self.formView.distribution = .fillProportionally
    self.formView.spacing = 6.0
    
    self.formView.setCustomSpacing(100, after: descriptionLabel)
    
    
    self.mainStackView = UIStackView(arrangedSubviews: [
      
      formView,
    ])
    
    self.mainStackView.axis = .vertical
    self.mainStackView.distribution = .fill
      //    self.mainStackView.isLayoutMarginsRelativeArrangement = true
    self.mainStackView.spacing = 0.0
    
    
//    self.mainStackView.setCustomSpacing(230.0, after: formView)
//    self.mainStackView.setCustomSpacing(8.0, after: submitButton)
    
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = false
    
    let birthDateGesture = UITapGestureRecognizer(target: self, action: #selector(birthdateInputTapped))
    let expiryDateGesture = UITapGestureRecognizer(target: self, action: #selector(expiryDateInputTapped))
    
    birthdateInput.field.addGestureRecognizer(birthDateGesture)
    expirydateInput.field.addGestureRecognizer(expiryDateGesture)
      //        addSubviews()
    setNFCFormUIConstraints()
  }
  private func setNFCFormUIConstraints() {
    addSubview(mainStackView)
    addSubview(submitButton)
    addSubview(amaniLogo)
    NSLayoutConstraint.activate([
  
      descriptionLabel.heightAnchor.constraint(equalToConstant: 20),
  
      mainStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
      mainStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
      mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
//      mainStackView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -6),
      
      submitButton.topAnchor.constraint(greaterThanOrEqualTo: mainStackView.bottomAnchor, constant: 20),
      submitButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
      submitButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
      submitButton.bottomAnchor.constraint(equalTo: amaniLogo.topAnchor, constant: -20),
      
      submitButton.heightAnchor.constraint(equalToConstant: 50.0),
      amaniLogo.widthAnchor.constraint(equalToConstant: 114),
      amaniLogo.heightAnchor.constraint(equalToConstant: 13),
      amaniLogo.centerXAnchor.constraint(equalTo: centerXAnchor),
      amaniLogo.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)
    ])
  
    expirydateInput.field.addSubview(expiryDataPicker)
    expiryDataPicker.translatesAutoresizingMaskIntoConstraints = false
    expiryDataPicker.contentHorizontalAlignment = .center
    
    birthdateInput.field.addSubview(birthDatePicker)
    birthDatePicker.translatesAutoresizingMaskIntoConstraints = false
    birthDatePicker.contentHorizontalAlignment = .center
    
    NSLayoutConstraint.activate([
      expiryDataPicker.leadingAnchor.constraint(equalTo: expirydateInput.field.leadingAnchor),
      expiryDataPicker.centerYAnchor.constraint(equalTo: expirydateInput.field.centerYAnchor),
      birthDatePicker.leadingAnchor.constraint(equalTo: birthdateInput.field.leadingAnchor),
      birthDatePicker.centerYAnchor.constraint(equalTo: birthdateInput.field.centerYAnchor),
    ])
    documentNoInput.setDelegate(delegate: self)
    birthdateInput.setDelegate(delegate: self)
    expirydateInput.setDelegate(delegate: self)
  }
}

extension NFCConfigureView: UITextFieldDelegate {

  func textFieldDidChangeSelection(_ textField: UITextField) {
    if textField == documentNoInput.field {
      documentNoInput.field.text = textField.text
      self.newDocumentNo = documentNoInput.field.text
    }
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == documentNoInput {
      expirydateInput.becomeFirstResponder()
    } else if textField == expirydateInput {
      birthdateInput.becomeFirstResponder()
    } else if textField == birthdateInput {
      return true
    }
    return true
  }
  
//  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//    guard textField == birthdateInput.field else {
//      return true
//    }
//    
//    guard let text = textField.text else {
//      return true
//    }
//    
//    let cleanedText = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//    let rangeOfTextToReplace = Range(range, in: cleanedText) ?? cleanedText.endIndex ..< cleanedText.endIndex
//    
//      // Check if it's a backspace press
//    if string.isEmpty {
//      var newText = cleanedText
//      if text.count == 1 {
//        newText = ""
//        textField.text = newText
////        viewModel.birthDay = newText
//        return false
//      }
//      
//      newText.remove(at: newText.index(before: rangeOfTextToReplace.lowerBound))
//      newText = formatAsDate(for: newText)
//      textField.text = newText
//      
//      return false
//    }
//    
//    var newText = cleanedText
//    newText.replaceSubrange(rangeOfTextToReplace, with: string)
//    newText = formatAsDate(for: newText)
//    textField.text = newText
////    viewModel.birthDay = newText
//    return false
//  }
}

