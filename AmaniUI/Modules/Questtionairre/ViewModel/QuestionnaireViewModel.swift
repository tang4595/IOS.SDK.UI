//
//  QuestionnaireViewModel.swift
//  AmaniUI
//
//  Created by Deniz Can on 25.01.2024.
//

import AmaniSDK
import Combine
import Foundation

class QuestionnaireViewModel {
  @Published var questions: [QuestionModel] = []
  @Published var answers: [QuestionAnswerRequestModel] = []
  private let questionnaire = Amani.sharedInstance.questionnaire()

  enum ViewState {
    case loading
    case success
    case failed
    case none
  }

  @Published var state: ViewState = .none

  init() {
    questionnaire.getQuestions(completion: { questions in
      self.questions = questions.sorted { $0.sortOrder < $1.sortOrder }
      // PREFILL THE ANSWERS FOR EASY MODIFICATION
      self.answers = self.questions.map { QuestionAnswerRequestModel(questionID: $0.id)}
    })
  }

  func addSingleAnswer(for questionID: String, answerID: String) {
    if let index = answers.firstIndex(where: { $0.question == questionID }) {
      // Modify existing answer
      if answers[index].singleOptionAnswer == answerID {
        // Uncheck if already checked
        answers[index].singleOptionAnswer = ""
      } else {
        // Check the new answer
        answers[index].singleOptionAnswer = answerID
      }
    }
  }
  
  func addMultipleAnswer(for questionID: String, answerID: String) {
    if let index = answers.firstIndex(where: { $0.question == questionID }) {
      if var answerToModify = answers[index].multipleOptionAnswer {
        if let indexToRemove = answerToModify.firstIndex(of: answerID) {
          // Unchecked, remove from array
          answerToModify.remove(at: indexToRemove)
        } else {
          // Newly checked, append to array
          answerToModify.append(answerID)
        }
        answers[index].multipleOptionAnswer = answerToModify
      } else {
        // No multipleOptionAnswer, create new array
        answers[index].multipleOptionAnswer = [answerID]
      }
    }
  }


  func submitAnswers() {
    state = .loading
    questionnaire.submitAnswers(answers: answers,
                                completion: { [weak self] answerState in
                                  self?.state = answerState ? .success : .failed
                                })
  }

  func getNextEmptyRequiredIndex() -> Int? {
    var answeredIndices = Set<Int>()
    
    answers = answers.sorted { answer1, answer2 in
      guard let question1 = questions.first(where: { $0.id == answer1.question }),
            let question2 = questions.first(where: { $0.id == answer2.question }) else {
        return false // Handle cases where the question for an answer is not found
      }
      return question1.sortOrder < question2.sortOrder
    }
    
    for (_, answer) in answers.enumerated() {
      if let questionIndex = questions.firstIndex(where: { $0.id == answer.question }) {
        let question = questions[questionIndex]
        // Check if required and not answered
        if !question.optional {
          if let multipleOptionAnswer = answer.multipleOptionAnswer, !multipleOptionAnswer.isEmpty {
            // Check if multipleOptionAnswer has one or more strings
            answeredIndices.insert(questionIndex)
          } else if let singleOptionId = answer.singleOptionAnswer, !singleOptionId.isEmpty {
            // Check if singleOptionAnswer is not nil or an empty string
            answeredIndices.insert(questionIndex)
          }
        }
      }
    }
    
    for (index, question) in questions.enumerated() {
      if !answeredIndices.contains(index) && !question.optional {
        return index
      }
    }
    
    return nil
  }
  
}
