//
//  SelfieRunnable.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 3.11.2022.
//

import AmaniSDK
import UIKit
import CoreServices

class DocumentsHandler: NSObject, DocumentHandler{
  var topVC: UIViewController
  var stepViewModel: KYCStepViewModel
  var docID: DocumentID
  var stepView: UIView?
  var files:[FileWithType]?
  var ContainerVC:ContainerViewController
  var callback:StepCompletionCallback?
  
  // Might be Selfie, AutoSelfie or PoseEstimation.
  private var documentsModule: Document!
  
  required init(topVC: UIViewController, stepVM: KYCStepViewModel, docID: DocumentID) {
    self.topVC = topVC
    self.stepViewModel = stepVM
    self.docID = docID
    ContainerVC = ContainerViewController(
      nibName: String(describing: ContainerViewController.self),
      bundle: Bundle(for: ContainerViewController.self)
    )
  }
  
  func start(docStep: AmaniSDK.DocumentStepModel, version: AmaniSDK.DocumentVersion, workingStepIndex: Int,completion: @escaping StepCompletionCallback) {
    callback = completion

    self.topVC.navigationController?.pushViewController(ContainerVC, animated: true)
    guard let appConfig = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs else {
      print("AppConfigError")
      return
    }
    ContainerVC.setNavigationRightButton(text: appConfig.uploadPdf ?? "Upload PDF" ,TintColor: appConfig.topBarFontColor)
    ContainerVC.setRightNavBarButtonAction {
      DispatchQueue.main.async {
      let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String ], in: .import)
      documentPicker.delegate = self
      if #available(iOS 11.0, *) {
          documentPicker.allowsMultipleSelection = false
      }
  //      navigationController?.pushViewController(documentPicker, animated: true)
        self.ContainerVC.present(documentPicker, animated: true)
      }
    }
    
    ContainerVC.bind(animationName:nil, docStep: version.steps![steps.front.rawValue], step:steps.front) {[weak self] () in
      var documentView:UIView = UIView()
      guard let self else {return}
      documentView = self.runDocumentsScan(
        step: docStep,
        version: version,
        completion: completion
      )!
      self.ContainerVC.view.addSubview(documentView)
      self.ContainerVC.view.bringSubviewToFront(documentView)
    }
  }
  
  func upload(completion: @escaping StepUploadCallback) {
    guard let documentsModule = documentsModule else { return }
    print(files)
    if let files = files {
      documentsModule.upload(
        location: AmaniUI.sharedInstance.location,
        files: files,
        completion: completion)
      self.files = nil
    }
    else {
      documentsModule.upload(
        location: AmaniUI.sharedInstance.location,
        completion: completion)

    }
  }

  
  private func runDocumentsScan(step: DocumentStepModel, version: DocumentVersion, completion: @escaping StepCompletionCallback) -> UIView?{
    documentsModule = Amani.sharedInstance.document()
    do {
      guard let type = version.type else {
        print("Type is not setted")
        return nil
      }
      documentsModule.setType(type: type )
      stepView = try documentsModule.start {[weak self] image in
        self?.stepView?.removeFromSuperview()
        completion(.success(self!.stepViewModel))
        self?.topVC.navigationController?.popToViewController(ofClass: HomeViewController.self)
      }
      return stepView
//      self.showStepView(navbarHidden: false)
    } catch let err {
      print(err)
      
      completion(.failure(.moduleError))
      return nil
    }
  }
  
}
