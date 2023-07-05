//
//  NFRunner.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 3.11.2022.
//

import AmaniSDK
import UIKit

class NFHandler: DocumentHandler {
  var topVC: UIViewController
  var stepViewModel: KYCStepViewModel
  var docID: DocumentID
  var stepView: UIView?
  
  private var nfcCaptureModule = Amani.sharedInstance.scanNFC()
  
  required init(topVC: UIViewController, stepVM: KYCStepViewModel, docID: DocumentID) {
    self.topVC = topVC
    self.stepViewModel = stepVM
    self.docID = docID
  }
  
  func start(docStep: AmaniSDK.DocumentStepModel, version: AmaniSDK.DocumentVersion, workingStepIndex: Int = 0,completion: @escaping StepCompletionCallback) {
    nfcCaptureModule.setType(type: version.type!)
    
    if AmaniUIv1.sharedInstance.getNvi() == nil {
      stepView = nfcCaptureModule.start(idCardType: DocumentTypes.TurkishIdNew.rawValue) { (nfcreq, error) in
        if let error = error {
          print(error)
          completion(.failure(.moduleError))
          return
        }
        completion(.success(self.stepViewModel))
      }
      
      self.showStepView(navbarHidden: false)
      return
    } else {
      guard let nviData = AmaniUIv1.sharedInstance.getNvi() else { return }
      
      do {
        try nfcCaptureModule.start(nviData: nviData) { (nfcReq, err) in
          completion(.success(self.stepViewModel))
        }
      } catch let err {
        print(err)
        completion(.failure(.moduleError))
      }
      
    }
    
  }
  
  func upload(completion: @escaping StepUploadCallback) {
    nfcCaptureModule.upload(location: AmaniUIv1.sharedInstance.location,
                            completion: completion)
  }
  
  
}
