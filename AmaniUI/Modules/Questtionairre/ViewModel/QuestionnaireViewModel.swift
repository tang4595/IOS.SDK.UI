//
//  QuestionnaireViewModel.swift
//  AmaniUI
//
//  Created by Deniz Can on 25.01.2024.
//

import Foundation
import Combine
import AmaniSDK

class QuestionnaireViewModel {
  @Published var questions: [QuestionModel] = []
  @Published var answers: [QuestionAnswerRequestModel] = []
  
  private let questionnaire = Amani.sharedInstance.questionnaire()
  
  init() {
    questionnaire.getQuestions(completion: { questions in
      self.questions = questions
    })
  }
  
  func addAnswer(for questionID: String, type: String) {
    
  }
  
}
