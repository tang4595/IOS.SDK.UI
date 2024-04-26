//
//  DocConfirmationViewController.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 5.10.2022.
//

import UIKit
import AmaniSDK

typealias ConfirmCallback = () -> Void

class DocConfirmationViewController: BaseViewController {
  
  @IBOutlet weak var lblView: UIView!
  @IBOutlet weak var imgOuterView: UIImageView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var physicalContractImageView: UIImageView!
  @IBOutlet weak var previewHeightConstraints: NSLayoutConstraint!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var tryAgainBtn: UIButton!
  @IBOutlet weak var confirmBtn: UIButton!
  @IBOutlet weak var selfieImageView: UIImageView!
  @IBOutlet weak var poweredByImg: UIImageView!
  
  @IBOutlet weak var idImgView: UIImageView!
  private var ovalView: OvalOverlayView!
  
  private var image: UIImage?
  private var confirmCallback: ConfirmCallback?
  
  private var documentID: DocumentID?
  private var documentVersion: DocumentVersion?
  private var documentStep: DocumentStepModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let appBackground = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs?.appBackground
    ovalView = OvalOverlayView(bgColor: UIColor(hexString: appBackground ?? "253C59"), strokeColor: UIColor(hexString: "ffffff engine='xlsxwrite"), screenBounds: UIScreen.main.bounds)
    
    self.initialSetup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
  }
  
  func initialSetup() {
    let appConfig = try! Amani.sharedInstance.appConfig().getApplicationConfig()
    let buttonRadious = CGFloat(appConfig.generalconfigs?.buttonRadius ?? 10)
    // Setting labels
    titleLabel.text = documentStep?.confirmationTitle ?? ""
    descriptionLabel.text = documentStep?.confirmationDescription ?? ""
    titleLabel.textColor = UIColor(hexString: appConfig.generalconfigs?.appFontColor ?? "ffffff")
    descriptionLabel.textColor = UIColor(hexString: appConfig.generalconfigs?.appFontColor ?? "ffffff")
    // Buttons corner radious
    tryAgainBtn.addCornerRadiousWith(radious: buttonRadious)
    confirmBtn.addCornerRadiousWith(radious: buttonRadious)
    // Setting titles
    tryAgainBtn.setTitle(appConfig.generalconfigs?.tryAgainText, for: .normal)
    confirmBtn.setTitle(appConfig.generalconfigs?.confirmText, for: .normal)
    // Border color for try again button
    tryAgainBtn.addBorder(borderWidth: 2, borderColor: UIColor(hexString: appConfig.generalconfigs?.secondaryButtonBorderColor ?? ThemeColor.whiteColor.toHexString()).cgColor)
    // Title Colors
    tryAgainBtn.setTitleColor(UIColor(hexString: appConfig.generalconfigs?.secondaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
    confirmBtn.setTitleColor(UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
    // Background Colors
    confirmBtn.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBackgroundColor ?? ThemeColor.primaryColor.toHexString())
    if let color = appConfig.generalconfigs?.secondaryButtonBackgroundColor {
      tryAgainBtn.backgroundColor = UIColor(hexString: color)
    }
    
    // Navigation Bar
    self.setNavigationBarWith(title: documentStep?.confirmationTitle ?? "", textColor: UIColor(hexString: appConfig.generalconfigs?.topBarFontColor ?? "ffffff"))
    self.setNavigationLeftButton(TintColor: appConfig.generalconfigs?.topBarFontColor ?? "ffffff")
    
    // labels and powered by image
    poweredByImg.tintColor = UIColor(hexString: appConfig.generalconfigs?.appFontColor ?? "ffffff")
    poweredByImg.isHidden = appConfig.generalconfigs?.hideLogo ?? false
    
    // Document spesific settings
    // Selfie
    if documentID == DocumentID.SE {
      titleLabel.isHidden = true
      physicalContractImageView.isHidden = true
      imgOuterView.isHidden = true
      
      selfieImageView.image = image
      selfieImageView.isHidden = false
      selfieImageView.contentMode = .scaleAspectFill
      let ovalView = OvalOverlayView(
        bgColor: UIColor(hexString: appConfig.generalconfigs?.appBackground ?? "", alpha: 1),
        strokeColor: UIColor(hexString: "ffffff"),
        screenBounds: UIScreen.main.bounds
      )
      
      self.view.bringSubviewToFront(selfieImageView)
//      self.view.addSubview(ovalView)
//      self.view.bringSubviewToFront(ovalView)
      self.view.bringSubviewToFront(stackView)
      self.view.bringSubviewToFront(poweredByImg)
      self.view.bringSubviewToFront(lblView)
    }
    // Contract or Utility Bill
    else if documentID == DocumentID.CO || documentID == DocumentID.UB||documentID == DocumentID.IB {
      imgOuterView.isHidden = true
      self.setNavigationBarWith(title: (self.documentStep?.confirmationTitle)!)
      self.physicalContractImageView.image = image
      physicalContractImageView.isHidden = false
      titleLabel.isHidden = true
      selfieImageView.isHidden = true
    }
    // For everything else
    else {
      imgOuterView.isHidden = false
      self.idImgView.image = image
      self.idImgView.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.appBackground ?? "#263B5B")
//      self.previewHeightConstraints.constant = (UIScreen.main.bounds.width - 46) * CGFloat((documentVersion?.aspectRatio!)!)
//      self.previewHeightConstraints.isActive = true
      self.view.layoutIfNeeded()
      titleLabel.isHidden = false
      selfieImageView.isHidden = true
      physicalContractImageView.isHidden = true
    }
    
//    if let errorList = idCaptureResponseModel?.errors{
//      if !errorList.isEmpty{
//        AlertDialogueUtility.shared.showMsgAlertWithHandler(controller: self, alertTitle:  (AppConfigUtility.shared.getAppConfiguration()?.generalconfigs?.tryAgainText)!, message: errorList[0].errorMessage, successTitle: Localization.okTitle.description,success:{ _ in
//          if self.attempt ?? 3 < 2{
//            self.confirmBtn.isEnabled = false
//            self.confirmBtn.alpha = 0.6
//            self.tryAgainBtn.isEnabled = true
//            self.tryAgainBtn.alpha = 1
//            if let completion = self.nfcCompletion {
//              completion(true)
//            }
//          }
//          else{
//            self.confirmBtn.isEnabled = true
//            self.confirmBtn.alpha = 1
//            self.tryAgainBtn.isEnabled = false
//            self.tryAgainBtn.alpha = 0.6
//          }
//        })
//      }
//    }
    
  }
  
  func bind(image: UIImage, documentID: DocumentID, docVer: DocumentVersion, docStep: DocumentStepModel, callback: @escaping ConfirmCallback) {
    self.image = image
    self.documentID = documentID
    self.documentVersion = docVer
    self.documentStep = docStep
    self.confirmCallback = callback
  }
  
  
  @IBAction func tryAgainAction(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  
  @IBAction func confirmAction(_ sender: Any) {
    if let confirmCallback = confirmCallback {
      confirmCallback()
    }
  }
  
  
}
