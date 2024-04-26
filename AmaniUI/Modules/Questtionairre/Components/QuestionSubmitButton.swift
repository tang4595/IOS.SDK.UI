//
//  QuestionSubmitButton.swift
//  AmaniUI
//
//  Created by Deniz Can on 6.02.2024.
//

import Foundation
import UIKit

class QuestionSubmitButton: UIStackView {
  public var nextCallback: (() -> Void)?
  
  private lazy var submitButton: UIButton = {
    let submit = UIButton()
    submit.setTitle("NEXT", for: .normal)
    submit.setTitleColor(.white, for: .normal)
    submit.backgroundColor = UIColor(hexString: "#EA3365")
    submit.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
      submit.addCornerRadiousWith(radious: 25.0)
    return submit
  }()
  
  @objc
  func didTapNext() {
    if let nextCallback = nextCallback {
      nextCallback()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(_ nextCb: @escaping (() -> Void)) {
    self.nextCallback = nextCb
  }
  
    func setupUI() {
        self.backgroundColor = UIColor(hexString: "#EEF4FA")
        self.addArrangedSubview(submitButton)
        self.axis = .vertical
        self.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: 20)
        self.isLayoutMarginsRelativeArrangement = true
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true

    }
}
