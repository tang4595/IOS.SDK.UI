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
  
  let questionnaireViewModel = QuestionnaireViewModel()
  
  override func viewDidLoad() {
    questionnaireView = QuestionnaireView()
    view.addSubview(questionnaireView)
    questionnaireView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      // FIXME: After implementing table view, change this
      questionnaireView.topAnchor.constraint(equalTo: view.topAnchor),
      questionnaireView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      questionnaireView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      questionnaireView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
  
}
