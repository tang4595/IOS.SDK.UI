//
//  QuestionnaireView.swift
//  AmaniUI
//
//  Created by Deniz Can on 25.01.2024.
//

import AmaniSDK
import Foundation
import UIKit

class QuestionnaireView: UIView {
  private var questions: [QuestionModel] = []
  private let questionnaire = Amani.sharedInstance.questionnaire()
  private var viewModel: QuestionnaireViewModel?
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.dataSource = self
    tableView.register(QuestionViewCell.self, forCellReuseIdentifier: String(describing: QuestionViewCell.self))
    return tableView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    questionnaire.getQuestions { [weak self] questions in
      self?.questions = questions.sorted { $0.sortOrder < $1.sortOrder }
      DispatchQueue.main.async {
        self?.setupUI()
      }
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupUI() {
    addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}

extension QuestionnaireView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return questions.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let questionForCell = questions[indexPath.item]
    
    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: QuestionViewCell.self), for: indexPath) as! QuestionViewCell
    cell.isConfigured = false
    cell.question = questionForCell
    cell.configure(delegate: self)
    
    return cell
  }
 }

extension QuestionnaireView: QuestionDelegate {
  func didTapAnswer(answerID: String, questionType: String) {
    // TODO: Add answer to viewModel
    print(answerID)
    print(questionType)
  }
}
