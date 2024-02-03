//
//  AnswerButton.swift
//  AmaniUI
//
//  Created by Deniz Can on 25.01.2024.
//

import AmaniSDK
import Foundation
import UIKit

enum AnswerButtonType {
  case multiple
  case single
}

class AnswerButton: UIButton {
  private var question: QuestionAnswerModel?
  private var type: AnswerButtonType = .single
  private var didPressCallback: ((String) -> Void)?

  private lazy var checkMark: UIImageView = {
    let image = UIImage(systemName: "square")?.withTintColor(.black)
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private var isChecked = false {
    didSet {
      let image = isChecked ? UIImage(systemName: "square.fill") : UIImage(systemName: "square")
      setImage(image!, for: .normal)
    }
  }

  convenience init(
    with question: QuestionAnswerModel,
    type: AnswerButtonType = .single
  ) {
    self.init()
    self.question = question
    self.type = type

    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 15.0, weight: .light),
      .foregroundColor: UIColor(hexString: "#565656"),
    ]

    let attributedString = NSAttributedString(
      string: question.title,
      attributes: attributes
    )

    setAttributedTitle(attributedString, for: .normal)

    tintColor = .black
    backgroundColor = .white

    titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)

    layer.borderColor = UIColor(hexString: "#C0C0C0").cgColor
    layer.borderWidth = 1.0

    if type == .multiple {
      setImage(UIImage(systemName: "square"),
               for: .normal)

      if let titleLabel = titleLabel {
        NSLayoutConstraint.activate([
          titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
          titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
        ])
      }
    }

    titleLabel?.numberOfLines = 3
    contentHorizontalAlignment = .leading

    if #available(iOS 15.0, *) {
      var configuration = UIButton.Configuration.plain()
      configuration.contentInsets = NSDirectionalEdgeInsets(
        top: 16,
        leading: 20,
        bottom: 16,
        trailing: 20)
      configuration.imagePadding = 10
      self.configuration = configuration
    } else {
      contentEdgeInsets = UIEdgeInsets(
        top: 16,
        left: 20,
        bottom: 16,
        right: 20
      )
    }

    heightAnchor.constraint(greaterThanOrEqualToConstant: 50).priority = .required
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    // Overriding in init doesn't work
    guard imageView?.image != nil else { return }
    if let imageView = imageView {
      imageView.translatesAutoresizingMaskIntoConstraints = false
      let sizeConstraints = [
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
        imageView.widthAnchor.constraint(equalToConstant: 18.0),
        imageView.heightAnchor.constraint(equalToConstant: 18.0),
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      ]
      sizeConstraints.forEach { $0.priority = .required }
      NSLayoutConstraint.activate(sizeConstraints)
      imageView.contentMode = .scaleAspectFit
    }
  }

  func bind(didPressAnswerFN: @escaping (String) -> Void) {
    self.didPressCallback = didPressAnswerFN
    self.addTarget(self, action: #selector(didTapAnswer), for: .touchUpInside)
  }
  
  @objc
  func didTapAnswer() {
    if type == .multiple {
      isChecked.toggle()
    }
    
    if let cb = self.didPressCallback {
      cb(self.question!.id)
    }
  }
  
}
