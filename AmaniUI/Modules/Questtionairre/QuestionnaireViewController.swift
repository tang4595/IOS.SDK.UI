//
//  QuestionnaireViewController.swift
//  AmaniUI
//
//  Created by Deniz Can on 25.01.2024.
//

import Foundation
import UIKit

class QuestionnaireViewController: BaseViewController {
  private var questionnaireView: QuestionnaireView!
  private var handler: (() -> Void)? = nil
  
  let questionnaireViewModel = QuestionnaireViewModel()
  
  override func viewDidLoad() {
    questionnaireView = QuestionnaireView()
    view.addSubview(questionnaireView)
    questionnaireView.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(hexString: "#EEF4FA")
    questionnaireView.bind(with: questionnaireViewModel, completionHandler: handler!)
    NSLayoutConstraint.activate([
      questionnaireView.topAnchor.constraint(equalTo: view.topAnchor),
      questionnaireView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      questionnaireView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      questionnaireView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
  
  func setCompletionHandler(_ handler: @escaping (() -> Void)) {
    self.handler = handler
  }
  
}
