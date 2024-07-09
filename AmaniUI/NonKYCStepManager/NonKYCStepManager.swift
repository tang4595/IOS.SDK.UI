//
//  PreKYCStepManager.swift
//  AmaniUI
//
//  Created by Deniz Can on 12.01.2024.
//

import AmaniSDK
import Foundation
import UIKit

class NonKYCStepManager {
  var preSteps: [KYCStepViewModel] = []
  var postSteps: [KYCStepViewModel] = []
  let customerVC: UIViewController
  public var navigationController: UINavigationController?
  private var completionHandler: ((UINavigationController?) -> Void)!
  private let customer: CustomerResponseModel
  private var steps: [KYCStepViewModel] = []
  private var currentStep: KYCStepViewModel!
  private var currentStepViewController: UIViewController?

  init(for steps: [AmaniSDK.StepConfig], customer: CustomerResponseModel, vc: UIViewController) {
    self.customer = customer
    customerVC = vc
    generate(for: steps, rules: customer.rules!)
  }

  /// If nil is returned from the completion callback it means there are no
  /// steps to start
  func startFlow(forPreSteps: Bool = true, completionCallback: @escaping (UINavigationController?) -> Void) {
    if forPreSteps {
      steps = preSteps
    } else {
      steps = postSteps
    }

    guard !steps.isEmpty else {
      completionCallback(nil)
      return
    }

    completionHandler = completionCallback
    executeStep()
  }

  private func executeStep() {
    currentStep = steps.removeFirst()

    switch AppConstants.StepsBeforeKYC(rawValue: currentStep.identifier!)! {
    case .phoneOTP:
      startPhoneOTP()
    case .emailOTP:
      startEmailOTP()
    case .profileInfo:
      startProfileInfo()
    case .questionnaire:
      startQuestionnaire()
    }
  }

  private func startEmailOTP() {
    if currentStep.status == DocumentStatus.APPROVED {
      stepCompleted()
      return
    }
      
      DispatchQueue.main.async {
    self.currentStepViewController = EmailOTPScreenViewController()
    let emailOTPVC = self.currentStepViewController as! EmailOTPScreenViewController
    
    emailOTPVC.bind(stepVM: self.currentStep)
    emailOTPVC.setCompletionHandler { [weak self] in
      self?.stepCompleted()
    }

   
      self.navigate(to: emailOTPVC)
    }
  }

  private func startPhoneOTP() {
    if currentStep.status == DocumentStatus.APPROVED {
      stepCompleted()
      return
    }
      
      DispatchQueue.main.async {
   self.currentStepViewController = PhoneOTPScreenViewController()
          let phoneOTPVC = self.currentStepViewController as! PhoneOTPScreenViewController
    
          phoneOTPVC.bind(stepVM: self.currentStep)
    phoneOTPVC.setCompletionHandler {[weak self] in
      self?.stepCompleted()
    }

 
      self.navigate(to: self.currentStepViewController!)
    }
  }

  private func startProfileInfo() {
    if currentStep.status == DocumentStatus.APPROVED {
      stepCompleted()
      return
    }

    DispatchQueue.main.async {
      self.currentStepViewController = ProfileInfoViewController()
    
    let profileInfoVC = self.currentStepViewController as! ProfileInfoViewController
    
        profileInfoVC.bind(with: self.currentStep)
    profileInfoVC.setCompletionHandler {[weak self] in
      self?.stepCompleted()
    }

      self.navigate(to: self.currentStepViewController!)
    }
  }
  
  private func startQuestionnaire() {
    if currentStep.status == DocumentStatus.APPROVED {
      stepCompleted()
      return
    }
    
    DispatchQueue.main.async {
      self.currentStepViewController = QuestionnaireViewController()
      let questionnaireVC = self.currentStepViewController as! QuestionnaireViewController
      questionnaireVC.bind(with: self.currentStep)
      questionnaireVC.setCompletionHandler {[weak self] in
        self?.stepCompleted()
      }
      
      self.navigate(to: self.currentStepViewController!)
    }
  }

  private func stepCompleted() {
    if steps.isEmpty {
      completionHandler(navigationController)
    } else {
      executeStep()
    }
  }

  private func navigate(to viewController: UIViewController) {
    if navigationController == nil {
      navigationController = UINavigationController(rootViewController: viewController)
      navigationController!.modalPresentationStyle = .fullScreen
      customerVC.present(navigationController!, animated: true)
    } else {
      navigationController!.setViewControllers([viewController], animated: true)
//      navigationController!.pushViewController(viewController, animated: true)
    }
  }
  
  private func generate(for steps: [AmaniSDK.StepConfig], rules: [AmaniSDK.KYCRuleModel]) {
    let allStepModels: [KYCStepViewModel?] = rules.map { ruleModel in
      if let stepModel = steps.first(where: { $0.id == ruleModel.id }) {
        return KYCStepViewModel(from: stepModel, initialRule: ruleModel, topController: customerVC)
      }
      return nil
    }
    
    let filtered = allStepModels.filter { $0 != nil } as! [KYCStepViewModel]
    
    if filtered.isEmpty {
      self.preSteps = []
      self.postSteps = []
      return
    }
    
    let sorted = filtered.sorted { $0.sortOrder < $1.sortOrder }
    
    let firstKYCIndex = sorted.firstIndex(where: { $0.identifier == "kyc" })
    let lastKYCIndex = sorted.lastIndex(where: { $0.identifier == "kyc" })
    
    if firstKYCIndex == 0 {
      preSteps = []
    } else {
      preSteps = Array(sorted[0 ... (firstKYCIndex!.advanced(by: -1))])
    }
    
    postSteps = Array(sorted[lastKYCIndex!.advanced(by: 1)...])
  }

  public func hasPostSteps() -> Bool {
    let approvedPostStepCount = postSteps.filter { $0.status == DocumentStatus.APPROVED }
    return approvedPostStepCount.count > 0
  }
}
