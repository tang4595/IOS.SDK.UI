//
//  NFRunner.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 3.11.2022.
//

import AmaniSDK
import UIKit

class NFHandler: DocumentHandler {
    func start(docStep: AmaniSDK.DocumentStepModel, version: AmaniSDK.DocumentVersion, workingStepIndex: Int, completion: @escaping StepCompletionCallback) {
        print("bu metod kullanımdan kaldırıldı.")
    }
    
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
  
    func start(docStep: AmaniSDK.DocumentStepModel, version: AmaniSDK.DocumentVersion, workingStepIndex: Int = 0,completion: @escaping StepCompletionCallback) async {
    // FIXME: Add correct id type to nf document on configuration
    nfcCaptureModule.setType(type: DocumentTypes.TurkishIdNew.rawValue)
        
      guard let nviData = AmaniUI.sharedInstance.getNvi() else { return }
        
        
      
      do {
        
        try await nfcCaptureModule.start(nviData: nviData)
          completion(.success(self.stepViewModel))
        
      } catch let err {
        print(err)
        completion(.failure(.moduleError))
      }

  }
  
  func upload(completion: @escaping StepUploadCallback) {
    nfcCaptureModule.upload(location: AmaniUI.sharedInstance.location){[weak self] result in
      completion(result,nil)
    }
  }
  
  
}
