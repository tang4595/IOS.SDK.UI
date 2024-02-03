//
//  QuestionDropdownView.swift
//  AmaniUI
//
//  Created by Deniz Can on 25.01.2024.
//

import AmaniSDK
import Foundation
import UIKit

class QuestionDropdownView: UIView {
  var question: QuestionModel?
  var didTapAnswerCallback: ((String) -> Void)?

  public var answersHidden: Bool = true {
    didSet {
      // FIXME: Since the table view doesn't want to update the cell height
      // automatically, this disables the show hide function for now.
      // Find a way to notify the changes to the table view
      
//      answerStackView.setIsHidden(!answersHidden, animated: true)
//      self.layoutIfNeeded()
//      self.superview?.layoutIfNeeded()
    }
  }

  private lazy var showHideButton: UIButton = {
    let button = UIButton()
    button.setTitle("Select the applicable options", for: .normal)
    button.tintColor = .black
    button.addCornerRadiousWith(radious: 10.0)
    button.addBorder(borderWidth: 1.0, borderColor: UIColor(hexString: "#565656").cgColor)
    button.backgroundColor = .white
    button.contentHorizontalAlignment = .fill

    if #available(iOS 15.0, *) {
      var configuration = UIButton.Configuration.plain()
      configuration.contentInsets = NSDirectionalEdgeInsets(
        top: 15.5,
        leading: 20.0,
        bottom: 15.5,
        trailing: 20)
      configuration.imagePlacement = .trailing
      button.configuration = configuration
    } else {
      // Fallback on earlier versions
      button.contentEdgeInsets = UIEdgeInsets(
        top: 15.5,
        left: 20.0,
        bottom: 15.5,
        right: 20
      )
    }

    button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
    return button
  }()

  private lazy var answerStackView: UIStackView = {
    let stackView = UIStackView()

    stackView.axis = .vertical

    stackView.layer.cornerRadius = 10.0
    stackView.layer.masksToBounds = true
    stackView.layer.borderWidth = 1.0
    stackView.layer.borderColor = UIColor(hexString: "#565656").cgColor
    return stackView
  }()

  convenience init(with question: QuestionModel) {
    self.init()
    self.question = question
    setupUI()
  }

  func setupUI() {
    guard let question = question else {
      return
    }

    let buttonType: AnswerButtonType = question.answerType == "multiple_choice" ? .multiple : .single
    question.answers.forEach { answer in
      let answerButton = AnswerButton(with: answer, type: buttonType)
      self.answerStackView.addArrangedSubview(answerButton)
    }

    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 16.0, weight: .regular),
      .foregroundColor: UIColor(hexString: "#565656"),
    ]

    let attributedString = NSAttributedString(
      string: buttonType == .single ? "Select" : "Select the applicable options",
      attributes: attributes
    )

    showHideButton.setAttributedTitle(attributedString, for: .normal)

    // Show hide button area
    showHideButton.translatesAutoresizingMaskIntoConstraints = false
    addSubview(showHideButton)

    answerStackView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(answerStackView)
    NSLayoutConstraint.activate([
      showHideButton.topAnchor.constraint(equalTo: topAnchor),
      showHideButton.heightAnchor.constraint(equalToConstant: 50.0),
      showHideButton.leadingAnchor.constraint(equalTo: leadingAnchor),
      showHideButton.trailingAnchor.constraint(equalTo: trailingAnchor),
      answerStackView.topAnchor.constraint(equalTo: showHideButton.bottomAnchor, constant: 8),
      answerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      answerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      // fucking culprit.
      answerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  func bind(didTapAnswerFunc: @escaping (String) -> Void) {
    didTapAnswerCallback = didTapAnswerFunc
    showHideButton.addTarget(self, action: #selector(showHideButtonAction), for: .touchUpInside)
    
    let answerButtons: [AnswerButton] = answerStackView.arrangedSubviews as! [AnswerButton]
    answerButtons.forEach { $0.bind(didPressAnswerFN: didTapAnswerFunc)}
    
  }

  @objc func showHideButtonAction() {
    answersHidden.toggle()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
  }
}
