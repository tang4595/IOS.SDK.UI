//
//  QuestionView.swift
//  AmaniUI
//
//  Created by Deniz Can on 1.02.2024.
//

import AmaniSDK
import Foundation
import UIKit

protocol QuestionDelegate {
  func didTapAnswer(questionID: String, answerID: String, questionType: String)
}

class QuestionViewCell: UITableViewCell {
  public var question: QuestionModel?
  private var delegate: QuestionDelegate?
  public var isConfigured = false
  
  private var dropdownView: QuestionDropdownView?
  private var singleOption: SingleAnswerButton?
    
    var genConfig: GeneralConfig? {
        didSet {
            setupUI()
        }
    }
  
  private lazy var questionTitle: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    label.textColor = .black
    label.numberOfLines = 0
    label.text = "Temporary title, please initialize correctly"
    return label
  }()
  
  private lazy var questionDescription: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 13.0, weight: .light)
    label.textColor = UIColor(hexString: "#465364")
    label.text = "Temporary title, please initialize correctly"
    return label
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [questionTitle])
    
    stackView.spacing = 8.0
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fillProportionally
    stackView.layer.masksToBounds = true
    
    return stackView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    // Reset the cell's state when preparing for reuse
    isConfigured = false
    dropdownView?.removeFromSuperview()
    dropdownView = nil
    singleOption?.removeFromSuperview()
    singleOption = nil
  }
  
  func configure(delegate: QuestionDelegate, selectedAnswers: QuestionAnswerRequestModel? = nil) {
    guard !isConfigured else { return }
    guard let question = question else { return }
    self.delegate = delegate
    questionTitle.text = question.title
    selectionStyle = .none
    
    if question.answers.count > 1 {
      configureDropDown(question: question, selectedAnswers: selectedAnswers)
    } else {
      configureSingleButton(question: question, selectedAnswers: selectedAnswers)
    }
  }
  
  func configureSingleButton(question: QuestionModel, selectedAnswers: QuestionAnswerRequestModel? = nil) {
    // Configuration for single option
    if singleOption == nil {
      let answerData = question.answers.first!
      singleOption = SingleAnswerButton(with: answerData)
      
      if selectedAnswers?.singleOptionAnswer != nil {
        singleOption?.setSelected(true)
      }
      
      singleOption?.sizeToFit()
      singleOption!.translatesAutoresizingMaskIntoConstraints = false
      singleOption!.bind { [weak self] answerID in
        self?.delegate?.didTapAnswer(questionID: question.id, answerID: answerID, questionType: question.answerType)
      }
    }
    
    stackView.addArrangedSubview(singleOption!)
    isConfigured = true
    singleOption!.layoutIfNeeded()
  }
  
  func configureDropDown(question: QuestionModel, selectedAnswers: QuestionAnswerRequestModel? = nil) {
    // Configuration for dropdown
    if dropdownView == nil {
      dropdownView = QuestionDropdownView(with: question, answers: selectedAnswers)
      dropdownView!.translatesAutoresizingMaskIntoConstraints = false
      dropdownView!.bind { [weak self] answerID in
        self?.delegate?.didTapAnswer(questionID: question.id, answerID: answerID, questionType: question.answerType)
      }
    }
    
    stackView.addArrangedSubview(dropdownView!)
    isConfigured = true
    dropdownView!.layoutIfNeeded()
  }
  
  func setupUI() {
    // pin.
    self.backgroundColor = UIColor(hexString: genConfig?.appBackground ?? "#EEF4FA")
    contentView.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30.0),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30.0),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
    ])
  }
}
