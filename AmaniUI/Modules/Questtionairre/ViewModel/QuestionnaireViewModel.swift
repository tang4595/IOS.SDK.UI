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
  @Published var answers: [QuestionAnswerRequestModel] = []
}
