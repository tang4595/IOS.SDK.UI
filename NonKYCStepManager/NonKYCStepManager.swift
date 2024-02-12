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

    let allStepModels: [KYCStepViewModel?] = customer.rules!.map { ruleModel in
      if ruleModel.status == DocumentStatus.APPROVED.rawValue { return nil }
      if let stepModel = steps.first(where: { $0.id == ruleModel.id }) {
        return KYCStepViewModel(from: stepModel, initialRule: ruleModel, topController: vc)
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

    guard let docVersion = currentStep.documents.first?.versions?.first
    else {
      print("Misconfigured email otp, ask Amani for corrections")
      stepCompleted()
      return
    }

    self.currentStepViewController = EmailOTPScreenViewController()
    let emailOTPVC = currentStepViewController as! EmailOTPScreenViewController
    
    emailOTPVC.bind(docVersion: docVersion)
    emailOTPVC.setCompletionHandler { [weak self] in
      self?.stepCompleted()
    }

    DispatchQueue.main.async {
      self.navigate(to: emailOTPVC)
    }
  }

  private func startPhoneOTP() {
    if currentStep.status == DocumentStatus.APPROVED {
      stepCompleted()
      return
    }

   self.currentStepViewController = PhoneOTPScreenViewController()

    (currentStepViewController as! PhoneOTPScreenViewController)
      .setCompletionHandler { [weak self] in
        self?.stepCompleted()
      }

    DispatchQueue.main.async {
      self.navigate(to: self.currentStepViewController!)
    }
  }

  private func startProfileInfo() {
    if currentStep.status == DocumentStatus.APPROVED {
      stepCompleted()
      return
    }

    DispatchQueue.main.sync {
      self.currentStepViewController = ProfileInfoViewController()
    }

    (currentStepViewController as! ProfileInfoViewController).setCompletionHandler { [weak self] in
      self?.stepCompleted()
    }

    DispatchQueue.main.sync {
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
      
      (self.currentStepViewController as? QuestionnaireViewController)!.setCompletionHandler {[weak self] in
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
      navigationController!.pushViewController(viewController, animated: true)
    }
  }

  public func hasPostSteps() -> Bool {
    return postSteps.count != 0
  }
}
