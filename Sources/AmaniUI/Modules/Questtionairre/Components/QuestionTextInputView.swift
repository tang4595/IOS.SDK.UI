//
//  QuestionTextInputView.swift
//  
//
//  Created by Y. Yılmaz Erdoğmuş on 24.01.2025.
//

import UIKit

//class QuestionTextInputView: UIView {
//  private var textChangedCallback: ((String) -> Void)?
//  
//  private lazy var textField: UITextField = {
//    let field = UITextField()
//    field.borderStyle = .roundedRect
//    field.placeholder = "Enter your answer"
//    field.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
//    return field
//  }()
//  
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    setupUI()
//  }
//  
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//  
//  private func setupUI() {
//    addSubview(textField)
//    textField.translatesAutoresizingMaskIntoConstraints = false
//    
//    NSLayoutConstraint.activate([
//      textField.topAnchor.constraint(equalTo: topAnchor),
//      textField.leadingAnchor.constraint(equalTo: leadingAnchor),
//      textField.trailingAnchor.constraint(equalTo: trailingAnchor),
//      textField.bottomAnchor.constraint(equalTo: bottomAnchor),
//      textField.heightAnchor.constraint(equalToConstant: 44)
//    ])
//  }
//  
//  func bind(_ callback: @escaping (String) -> Void) {
//    textChangedCallback = callback
//  }
//  
//  func setText(_ text: String) {
//    textField.text = text
//  }
//  
//  @objc private func textFieldDidChange() {
//    textChangedCallback?(textField.text ?? "")
//  }
//}
