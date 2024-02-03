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
  func didTapAnswer(answerID: String, questionType: String)
}

class QuestionViewCell: UITableViewCell {
  public var question: QuestionModel?
  private var delegate: QuestionDelegate?
  public var isConfigured = false

  private var dropdownView: QuestionDropdownView?

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
    label.font = UIFont.systemFont(ofSize: 13.0)
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

    return stackView
  }()

  //  override init(frame: CGRect) {
  //    super.init(frame: frame)
  //    setupUI()
  //  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(delegate: QuestionDelegate) {
    guard !isConfigured else { return }
    guard let question = question else { return }
    self.delegate = delegate
    questionTitle.text = question.title
    selectionStyle = .none

    // since whenever this component is dequeued. we need to replace the
    // dropdown view.

    if let existingDropdownView = dropdownView {
      stackView.removeArrangedSubview(existingDropdownView)
      // To delloacte.
      existingDropdownView.removeFromSuperview()
    }

    // Setting up the dropdown
    dropdownView = QuestionDropdownView(with: question)
    dropdownView!.translatesAutoresizingMaskIntoConstraints = false
    dropdownView!.bind { [weak self] answerID in
      self?.delegate?.didTapAnswer(answerID: answerID, questionType: question.answerType)
    }

    stackView.addArrangedSubview(dropdownView!)
    isConfigured = true
    dropdownView!.layoutIfNeeded()
  }

  func setupUI() {
    // pin.
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
