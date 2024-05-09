//
//  File.swift
//  Demo
//
//  Created by Münir Ketizmen on 26.01.2022.
//

import UIKit
import AmaniSDK
class SignatureViewController: BaseViewController {
    let amani:Amani = Amani.sharedInstance
    var viewContainer:UIView?
  var stepCount:Int = 0
  var docStep:DocumentStepModel?
  var documentVersion: DocumentVersion?
  var callback:((UIImage)->())?
    
  @IBOutlet weak var clearBtn: UIButton!
  @IBOutlet weak var confirmBtn: UIButton!
  
  @IBAction func ConfirmAct(_ sender: UIButton) {
        amani.signature().capture()
  }
    
  @IBAction func ClearAct() {
    amani.signature().clear()
  }
  
  func start(docStep: AmaniSDK.DocumentStepModel, version: AmaniSDK.DocumentVersion, completion: ((UIImage)->())?) {
    guard let steps = version.steps else {return}
    stepCount = steps.count
    self.documentVersion = version
    self.docStep = docStep
    self.callback = completion
    initialSetup()
    

  }
  override func viewWillAppear(_ animated: Bool) {
        do {
            let signature = amani.signature()
            signature.setViewArea(viewArea: view.bounds)
            
            signature.setConfirmButtonCallback {
              self.confirmBtn.isEnabled = true
            }
          
          signature.setOnConfirmPressedCallback { image, currentSignatureNo in
            print(image.cgImage?.width, image.cgImage?.height, currentSignatureNo)
          }
          
          guard let signatureView:UIView = try signature.start(stepId: stepCount, completion: { [weak self] (previewImage) in
                DispatchQueue.main.async {
                  guard let callback = self?.callback else {return}
                  callback(previewImage)
//                  callback(.success(self.stepViewModel))
//
//                    guard let previewVC:UIViewController  = self?.storyboard?.instantiateViewController(withIdentifier: "preview") else {return}
////                  ( previewVC as! DocConfirmationViewController).preImage = previewImage
//                    self?.navigationController?.pushViewController(previewVC, animated: true)
//                    self?.viewContainer?.removeFromSuperview()
                }
            }) else {return}
          
            DispatchQueue.main.async {
                self.viewContainer = signatureView
                self.view.addSubview(signatureView)
                self.view.bringSubviewToFront(self.confirmBtn)
                self.view.bringSubviewToFront(self.clearBtn)
            }
        }
        catch  {
            print("Unexpected error: \(error).")
        }
    }
  
  
  func initialSetup() {
    let appConfig = try! Amani.sharedInstance.appConfig().getApplicationConfig()
    let buttonRadious = CGFloat(appConfig.generalconfigs?.buttonRadius ?? 10)
    

    // Navigation Bar
    self.setNavigationBarWith(title: docStep?.captureTitle ?? "", textColor: UIColor(hexString: appConfig.generalconfigs?.topBarFontColor ?? "ffffff"))
    self.setNavigationLeftButton(TintColor: appConfig.generalconfigs?.topBarFontColor ?? "ffffff")
    self.view.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.appBackground ?? "#263B5B")
    confirmBtn.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBackgroundColor ?? ThemeColor.primaryColor.toHexString())
    confirmBtn.layer.borderColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBorderColor ?? "#263B5B").cgColor
    confirmBtn.setTitle(appConfig.generalconfigs?.confirmText, for: .normal)
    confirmBtn.setTitleColor(UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
    confirmBtn.tintColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString())
    confirmBtn.addCornerRadiousWith(radious: buttonRadious)
    
    let secondaryBackgroundColor:UIColor = appConfig.generalconfigs?.secondaryButtonBackgroundColor == nil ? UIColor.clear :UIColor(hexString: (appConfig.generalconfigs?.secondaryButtonBackgroundColor)!)

    clearBtn.backgroundColor = secondaryBackgroundColor
    clearBtn.addBorder(borderWidth: 1, borderColor: UIColor(hexString: appConfig.generalconfigs?.secondaryButtonBorderColor ?? "#263B5B").cgColor)
    clearBtn.setTitle(documentVersion?.clearText ?? "Temizle", for: .normal)
    clearBtn.setTitleColor(UIColor(hexString: appConfig.generalconfigs?.secondaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
    clearBtn.tintColor = UIColor(hexString: appConfig.generalconfigs?.secondaryButtonTextColor ?? ThemeColor.whiteColor.toHexString())
    clearBtn.addCornerRadiousWith(radious: buttonRadious)
      
      clearBtn.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
            clearBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            clearBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clearBtn.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -20),
            clearBtn.heightAnchor.constraint(equalToConstant: 50)
          ])
      
      confirmBtn.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
            confirmBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            confirmBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            clearBtn.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
            confirmBtn.heightAnchor.constraint(equalToConstant: 50)
          ])
      
//    // For everything else
//      imgOuterView.isHidden = false
//      self.idImgView.image = image

//      self.previewHeightConstraints.constant = (UIScreen.main.bounds.width - 46) * CGFloat((documentVersion?.aspectRatio!)!)
//      self.previewHeightConstraints.isActive = true
//      self.view.layoutIfNeeded()
//      titleLabel.isHidden = false
//      selfieImageView.isHidden = true
//      physicalContractImageView.isHidden = true
//
//
  }
    override func viewDidAppear(_ animated: Bool) {
    }
    
}
