//
//  BaseRunner.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 2.11.2022.
//

import UIKit
import AmaniSDK

protocol DocumentHandler {
  var topVC: UIViewController { get set }
  var stepViewModel: KYCStepViewModel { get set }
  var docID: DocumentID { get set }
  var stepView: UIView? { get set }
  
  init(topVC: UIViewController, stepVM: KYCStepViewModel, docID: DocumentID)
  
  func start(docStep: DocumentStepModel, version: DocumentVersion, workingStepIndex:Int, completion: @escaping StepCompletionCallback)
  
  func upload(completion: @escaping StepUploadCallback)
  
}

extension DocumentHandler {
  func startConfirmVC(image: UIImage, docStep: DocumentStepModel, docVer: DocumentVersion, completion: @escaping ConfirmCallback) {
    
    let confirmVC = DocConfirmationViewController(
      nibName: String(describing: DocConfirmationViewController.self),
      bundle: Bundle(for: DocConfirmationViewController.self)
    )
    
    confirmVC.bind(image: image, documentID: docID, docVer: docVer, docStep: docStep, callback: completion)
    
    self.topVC.navigationController?.pushViewController(confirmVC, animated: true)
  }
  
  func showStepView(navbarHidden: Bool) {
    guard let stepView = stepView else { return }
    DispatchQueue.main.async {
      self.topVC.view.addSubview(stepView)
      self.topVC.view.bringSubviewToFront(stepView)
      self.topVC.navigationController?.setNavigationBarHidden(navbarHidden, animated: false)
    }
  }
  
}
