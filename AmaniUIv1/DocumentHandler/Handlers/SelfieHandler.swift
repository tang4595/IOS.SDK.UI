//
//  SelfieRunnable.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 3.11.2022.
//

import AmaniSDK
import UIKit

class SelfieHandler: DocumentHandler {
  var topVC: UIViewController
  var stepViewModel: KYCStepViewModel
  var docID: DocumentID
  var stepView: UIView?
  
  // Might be Selfie, AutoSelfie or PoseEstimation.
  private var selfieModule: Any!
  
  required init(topVC: UIViewController, stepVM: KYCStepViewModel, docID: DocumentID) {
    self.topVC = topVC
    self.stepViewModel = stepVM
    self.docID = docID
  }
  
  func start(docStep: AmaniSDK.DocumentStepModel, version: AmaniSDK.DocumentVersion, workingStepIndex: Int,completion: @escaping StepCompletionCallback) {
    guard let selfieType = version.selfieType else {
      completion(.failure(.configError))
      return
    }
    let animationVC = ContainerViewController(
      nibName: String(describing: ContainerViewController.self),
      bundle: Bundle(for: ContainerViewController.self)
    )
    self.topVC.navigationController?.pushViewController(animationVC, animated: true)
    animationVC.bind(animationName: version.type!, docStep: version.steps![steps.front.rawValue], step:steps.front) {
      var selfieView:UIView = UIView()
      // Manual Selfie
      if selfieType == -1 {
        selfieView = self.runManualSelfie(
          step: docStep,
          version: version,
          completion: completion
        )!
      }
      else if selfieType == 0 {
        selfieView = self.runAutoSelfie(
          step: docStep,
          version: version,
          completion: completion
        )!
      } else if selfieType >= 1 {
        selfieView = self.runPoseEstimation(
          step: docStep,
          version: version,
          completion: completion
        )!
      }
      animationVC.view.addSubview(selfieView)
      animationVC.view.bringSubviewToFront(selfieView)
    }
  }
  
  func upload(completion: @escaping StepUploadCallback) {
    guard let selfieModule = selfieModule else { return }
    
    if (selfieModule is Selfie) {
      (selfieModule as! Selfie).upload( location: AmaniUIv1.sharedInstance.location,
                                        completion: completion)
    } else if (selfieModule is AutoSelfie){
      (selfieModule as! AutoSelfie).upload(location: AmaniUIv1.sharedInstance.location,
                                           completion: completion)
    } else if (selfieModule is PoseEstimation) {
      (selfieModule as! PoseEstimation).upload(location: AmaniUIv1.sharedInstance.location,
                                               completion: completion)
    }
    
  }
  
  private func runManualSelfie(step: DocumentStepModel, version: DocumentVersion, completion: @escaping StepCompletionCallback) -> UIView?{
    selfieModule = Amani.sharedInstance.selfie()
    guard let currentSelfieModule = selfieModule as? Selfie else {
      print("cant return")
      return nil
    }
    
    do {
      
      stepView = try currentSelfieModule.start { image in
        self.stepView?.removeFromSuperview()
        self.startConfirmVC(image: image, docStep: step, docVer: version) { [weak self] () in
          completion(.success(self!.stepViewModel))
          self?.topVC.navigationController?.popToViewController(ofClass: HomeViewController.self)
        }
      }
      return stepView
//      self.showStepView(navbarHidden: false)
    } catch let err {
      print(err)
      
      completion(.failure(.moduleError))
      return nil
    }
  }
  
  
  private func runAutoSelfie(step: DocumentStepModel, version: DocumentVersion, completion: @escaping StepCompletionCallback)-> UIView? {
    selfieModule = Amani.sharedInstance.autoSelfie()
    
    guard let currentSelfieModule = selfieModule as? AutoSelfie else {
      print("cant return")
      return nil
    }
    do {
      stepView = try currentSelfieModule.start { image in
        self.stepView?.removeFromSuperview()
        self.startConfirmVC(image: image, docStep: step, docVer: version) { [weak self] () in
          completion(.success(self!.stepViewModel))
          self?.topVC.navigationController?.popToViewController(ofClass: HomeViewController.self)
        }
      }
      return stepView
    } catch let err {
      print(err)
      completion(.failure(.moduleError))
      return nil
    }
  }
  
  private func runPoseEstimation(step: DocumentStepModel, version: DocumentVersion, completion: @escaping StepCompletionCallback)->UIView? {
    let poseCount = version.selfieType! + 1
    
    selfieModule = Amani.sharedInstance.autoSelfie()
    guard let currentSelfieModule = selfieModule as? PoseEstimation else {
      print("cant return")
      return nil
    }
    do {
      stepView = try currentSelfieModule.start(stepId: poseCount) { image in
        self.stepView?.removeFromSuperview()
        self.startConfirmVC(image: image, docStep: step, docVer: version) { [weak self] () in
          completion(.success(self!.stepViewModel))
          self?.topVC.navigationController?.popToViewController(ofClass: HomeViewController.self)
        }
      }
//      self.showStepView(navbarHidden: false)
      return stepView
    } catch let err {
      print(err)
      completion(.failure(.moduleError))
      return nil
    }
    
  }
  
}
